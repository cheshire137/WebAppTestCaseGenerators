require 'rubygems'
require 'ruby_parser'
require 'atomic_section.rb'
require 'range.rb'

module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
    include Enumerable
    include SharedAtomicSectionMethods
    extend SharedAtomicSectionMethods::ClassMethods
    include SharedChildrenMethods
    attr_reader :content, :initialized_content
    attr_accessor :source_file
    STATEMENT_END = /[\r\n;]/.freeze

    def [](obj)
      if obj.is_a?(Fixnum)
        each_with_index do |el, i|
          return el if el.index == obj || i == obj
        end
      elsif obj.respond_to?(:include?)
        i = 0
        select do |el|
          is_nil = el.index.nil?
          index_match = !is_nil && obj.include?(el.index)
          i_match = is_nil && obj.include?(i)
          result = index_match || i_match
          i += 1
          result
        end
      else
        nil
      end
    end

    def compress_content
      # Need to go in reverse lest we end up end up with unnested content
      (length-1).downto(0) do |i|
        element = self[i]
        next unless element.respond_to?(:close) &&
                    !element.close.nil? &&
                    element.respond_to?(:content)
        # element is open tag
        range = element.index+1...element.close.index
        content = self[range].compact
        next if content.nil? || content.empty?
        element.content = content.dup 
        content.each do |consumed_el|
          delete_node_check_size(consumed_el)
        end
        # Closing element is not part of the content, but it no longer
        # needs to appear as a separate element in the tree
        delete_node_check_size(element.close)
      end
    end

    def each
      if @initialized_content
        @content.each { |n| yield n }
      else
        yield node
        if !x.nil? && x.respond_to?(:each)
          x.each { |other| yield other }
        end
      end
    end

    def find_code_units
      code_elements = ERBDocument.extract_ruby_code_elements(@content)
      ERBDocument.find_code_units(code_elements, @content)
    end

    def get_atomic_sections_recursive(nodes=[])
      sections = []
      nodes.each do |node|
        sections << node if node.is_a?(AtomicSection)
        if node.respond_to?(:content) && !node.content.nil?
          sections += get_atomic_sections_recursive(node.content)
        end
        if node.respond_to?(:atomic_sections) && !node.atomic_sections.nil?
          sections += node.atomic_sections
        end
      end
      sections
    end

    def identify_atomic_sections
      section = AtomicSection.new
      @atomic_sections ||= []
      create_section = lambda do |cur_sec|
        @atomic_sections << cur_sec
        AtomicSection.new(cur_sec.count+1)
      end
      each do |child_node|
        if child_node.browser_output?
          unless section.try_add_node?(child_node)
            section = create_section.call(section)
#            section.parent = child_node
            section.try_add_node?(child_node)
          end
        elsif section.content.length > 0
          section = create_section.call(section)
#          section.parent = child_node
        end
      end
      # Be sure to get the last section appended if it was a valid one,
      # like in the case of an ERBDocument with a single node
      @atomic_sections << section if section.content.length > 0
    end

    def initialize_content
      @initialized_content = false
      @content = []
      each do |element|
        if element.respond_to?(:parent=)
          element.parent = self
        end
        @content << element
      end
      @initialized_content = true
    end

    def initialize_indices
      each_with_index do |element, i|
        element.index = i
      end
    end

    def inspect
      file_details = sprintf("Source file: %s", @source_file)
      sections = get_sections_and_nodes(:to_s)
      sprintf("%s\n%s", file_details, sections.join("\n"))
    end

    # Returns the number of HTML, ERB, and text nodes in this document
    def length
      if @initialized_content
        @content.length
      else
        1 + (x.respond_to?(:length) ? x.length : 0)
      end
    end

    def pair_tags
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :pair_match?
        # Find first matching mate for this element in the array of mateless
        # elements.  First matching mate will be latest added element.
        mate = mateless.find { |el| el.pair_match?(element) }
        if mate.nil?
          # Add mate to beginning of mateless array, so array is sorted by
          # most-recently-found to earliest-found.
          mateless.insert(0, element)
        else
          if mate.respond_to? :close
            mate.close = element
            mateless.delete(mate)
          else
            raise "Mate found out of order: " + mate.to_s + ", " + element.to_s
          end
        end
      end
    end

    def remove_duplicate_children
      each do |child|
        #puts "Looking at child: #{child.range}"
        has_content = child.respond_to?(:content) && !child.content.nil? && !child.content.empty?
        has_close = child.respond_to?(:close) && !child.close.nil?
        if has_content && has_close
          #puts "Deleting range #{child.content.first.index}..#{child.close.index}"
          delete_children_in_range(child.content.first.index, child.close.index)
        end
      end
    end

    def save_atomic_sections(base_dir='.')
      all_sections = get_atomic_sections_recursive((@atomic_sections || []) + (@content || []))
      if all_sections.nil? || all_sections.empty?
        raise "No atomic sections to write to file"
      end
      dir_name = sprintf("atomic_sections-%s",
        File.basename(@source_file).gsub(/\./, '_'))
      dir_path = File.join(base_dir, dir_name)
      puts sprintf("Creating directory %s...", dir_path)
      Dir.mkdir(dir_path)
      all_sections.collect do |section|
        file_name = sprintf("%04d.txt", section.count)
        file_path = File.join(dir_path, file_name)
        puts sprintf("Writing atomic section to file %s...", file_name)
        section.save(file_path)
        file_path
      end
    end

    def find_code_start_within_code(needle, haystack, split_needle)
      if needle.nil? || !needle.is_a?(String)
        raise ArgumentError, "Expected needle to be a string, got " + needle.class.name
      end
      if haystack.nil? || !haystack.is_a?(String)
        raise ArgumentError, "Expected haystack to be a string, got " + haystack.class.name
      end
      code_start = haystack.index(needle)
      return code_start unless code_start.nil?
      if split_needle.nil? || !split_needle.is_a?(Array)
        raise ArgumentError, "Expected split_needle to be non-nil array, got " + split_needle.class.name
      end
      # Lines of code may have been rejoined with \n when originally they were
      # only separated with ;, for example
      code_starts = split_needle.collect do |needle_piece|
        if needle_piece.strip.blank?
          :whitespace
        else
          haystack.index(needle_piece)
        end
      end
      if code_starts.empty?
        raise "Given split needle had no pieces:\nNeedle: #{needle}\nHaystack: #{haystack}\nSplit needle: #{split_needle.inspect}"
      end
      length_of_separator = 1
      #puts "Code starts: [" + code_starts.collect { |c| (c || 'nil').to_s }.join(', ') + ']'
      code_starts.each_with_index do |code_start, i|
        cur_needle = split_needle[i]
        if 0 == i
          if code_start.nil?
            raise "Could not find needle chunk ::#{cur_needle}:: within haystack #{haystack}"
          end
        elsif :whitespace != code_start
          prev_code_start = nil
          prev_index = i-1
          length_between = 0
          while prev_index >= 0 && :whitespace == code_starts[prev_index]
            length_between += split_needle[prev_index].length + length_of_separator
            prev_index -= 1
          end
          prev_code_start = code_starts[prev_index]
          prev_needle = split_needle[prev_index]

          if prev_code_start.nil?
            raise "Could not find needle chunk #{prev_needle} within haystack #{haystack}"
          end

          expected_code_start = prev_code_start + prev_needle.length + length_between + length_of_separator
          #puts "Expected code start #{expected_code_start}, instead got #{code_start}"

          if code_start.nil? || code_start != expected_code_start
            raise "Could not find ::#{needle}:: within ::#{haystack}:: in order to split multiple ERB statements in a single ERB tag into separate ERB tags; specifically could not find #{cur_needle}"
          end
        end
      end

      #puts "Index of #{needle} within #{haystack} is #{code_starts[0]}"

      # We did find all the chunks of the split_needle consecutively within
      # the haystack, so we can return the index of where the first chunk of
      # the split_needle was found in the haystack
      code_starts[0]
    end

    def split_out_erb_newlines
      index = 0
      num_children = @content.length
      while index < num_children
        child = @content[index]
        unless child.is_a?(ERBTag)
          index += 1
          next
        end
        code = child.ruby_code()
        unless code =~ STATEMENT_END
          index += 1
          next
        end
        split_code = code.split(STATEMENT_END)
        contained_units = ERBDocument.get_code_units(split_code)
        if contained_units.empty?
          contained_units = ERBDocument.split_out_ends(split_code)
        end
        #puts "This code:"
        #pp split_code
        #puts "Becomes these code units:"
        #pp contained_units
        unless contained_units.empty?
          child.overridden_ruby_code = code
          contained_units.each do |code_line|
            cur_code = child.overridden_ruby_code
            replace_index = find_code_start_within_code(code_line, cur_code, split_code)
            replace_index_end = replace_index + code_line.length
            before_chunk = cur_code[0...replace_index]
            after_chunk = cur_code[replace_index_end+1...cur_code.length]
            child_goes_before = false
            replacement_code = if before_chunk.nil? || before_chunk.blank?
                                 child_goes_before = true
                                 after_chunk || ''
                               elsif after_chunk.nil? || after_chunk.blank?
                                 child_goes_before = false
                                 before_chunk || ''
                               else
                                 child_goes_before = true
                                 before_chunk + after_chunk
                               end
            unless replacement_code.blank?
              new_child = child.dup()
              new_child.overridden_ruby_code = code_line
              child.overridden_ruby_code = replacement_code
              #puts "Replacing #{cur_code}\nWith #{child.overridden_ruby_code}"
              if child_goes_before
                #puts "Inserting new child before old child:\nNew child: " + new_child.to_s + "\nOld child: " + child.to_s
                @content.insert(index, new_child)
              else
                #puts "Inserting new child after old child:\nOld child: " + child.to_s + "\nNew child: " + new_child.to_s
                @content.insert(index+1, new_child)
              end
            end
          end
        end
        index += 1
      end # while
    end

    def to_s(indent_level=0)
      map(&:to_s).select { |str| !str.blank? }.join("\n")
    end

    private

      def delete_node_check_size(node_to_del)
        size_before = @content.length
        del_node_str = node_to_del.to_s
        @content.delete(node_to_del)
        if size_before - @content.length > 1
          raise "Deleted more than one node equaling\n" + del_node_str
        end
      end

      def self.extract_ruby_code_elements(nodes)
        code_els = []
        nodes.each do |el|
          if RubyCodeTypes.include?(el.class)
            code_els << el
          elsif el.respond_to?(:text_value)
            #puts "Converting type " + el.class.name + " to FakeERBOutput"
            code_els << FakeERBOutput.new(el.text_value, el.index)
          end
          if el.respond_to?(:content) && !(content = el.content).nil?
            # Recursively check content of this node for other code elements
            code_els += extract_ruby_code_elements(content)
          end
        end
        code_els
      end

      def self.find_code_units(code_elements, content)
        #puts "All code elements:"
        #pp code_elements
        num_elements = code_elements.length
        start_index = end_index = 0
        parser = RubyParser.new
        while start_index < num_elements
          while end_index < num_elements
            range = start_index..end_index
            #puts "Looking at range " + range.to_s
            unit_elements = code_elements[range]
            #pp unit_elements.map(&:class).map(&:name)
            unit_lines = unit_elements.map(&:ruby_code)#.map do |code_line|
#              code_line.split(NEW_LINE)
#            end.flatten
            #puts "--Checking code for code unit:"
            #pp unit_lines
            #puts "\n"
            end_index += 1
            begin
              sexp = parser.parse(unit_lines.join("\n"))
              #puts "Lines of code: " + unit_lines.join("\n")
              #puts "Sexp: "
              #pp sexp
              #puts ''
              setup_code_unit(unit_elements, sexp, content)
              start_index = end_index
            rescue Racc::ParseError
            end
          end

          # Once finding an outer code unit, should then check
          # start_index+1 to end_index-1 and so on inward to see if
          # any inner, nested code units exist
          start_index += 1
          end_index = start_index
        end
      end

      def self.get_code_units(code_elements)
        code_units = []
        num_elements = code_elements.length
        start_index = end_index = 0
        parser = RubyParser.new
        while start_index < num_elements
          while end_index < num_elements
            range = start_index..end_index
            unit_lines = code_elements[range]
            end_index += 1
            begin
              joined_lines = unit_lines.join("\n")
              # Call #dup because otherwise end up with pound sign added to
              # beginning (?!):
              parser.parse(joined_lines.dup())
              code_units << joined_lines
              start_index = end_index
            rescue Racc::ParseError
            end
          end

          # Once finding an outer code unit, should then check
          # start_index+1 to end_index-1 and so on inward to see if
          # any inner, nested code units exist
          start_index += 1
          end_index = start_index
        end
        code_units
      end

      def self.setup_code_unit(unit_elements, sexp, content)
        len = unit_elements.length
        if len < 1
          raise "Woah, how can I set up a code unit with no lines of code?"
        end
        opening = unit_elements.first
        opening.sexp = sexp if opening.respond_to?('sexp=')
        if len < 2
          #puts "--Found code unit:"
          #puts opening
          return
        end
        opening_tag_has_close = opening.respond_to?(:close)
        if opening_tag_has_close
          opening.close = unit_elements.last
        end
        included_content = content.select do |el|
          el.index > opening.index && (!opening_tag_has_close || el.index < opening.close.index)
        end
        #puts "--Found code unit:"
        #puts opening
        if opening.respond_to?(:content=)
          included_content.each do |child|
            if child.respond_to?(:parent=)
              child.parent = opening
            end
          end
          included_content.sort! { |a, b| section_and_node_sort(a, b) }
          opening.content = included_content
          #puts "--Now looking for code units in content:"
          #puts extract_ruby_code_elements(opening.content).map(&:to_s).join(",\n")
          #puts "---"
          find_code_units(extract_ruby_code_elements(opening.content), opening.content)
        end
      end

      def self.split_out_ends(code_lines)
        code_lines.collect do |line|
          unless line.nil?
            normalized_line = line.strip.downcase
            if 'end' == normalized_line || '}' == normalized_line
              line
            end
          end
        end.compact
      end
  end
end
