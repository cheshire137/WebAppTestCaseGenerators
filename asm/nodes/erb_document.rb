require 'rubygems'
require 'ruby_parser'
require 'atomic_section.rb'
require 'range.rb'

module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
    include Enumerable
    include SharedAtomicSectionMethods
    include SharedChildrenMethods
    attr_reader :content, :initialized_content
    attr_accessor :source_file
    @@parser = RubyParser.new

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
            section.try_add_node?(child_node)
          end
        elsif section.content.length > 0
          section = create_section.call(section)
        end
      end
      # Be sure to get the last section appended if it was a valid one,
      # like in the case of an ERBDocument with a single node
      @atomic_sections << section if section.content.length > 0
    end

    def initialize_content_and_indices
      @initialized_content = false
      @content = []
      each_with_index do |element, i|
        if element.respond_to?(:parent=)
          element.parent = self
        end
        @content << element
        element.index = i
      end
      @initialized_content = true
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
        num_elements = code_elements.length
        start_index = end_index = 0
        while start_index < num_elements
          #puts "Looking at range " + (start_index..end_index).to_s
          while end_index < num_elements
            range = start_index..end_index
            #puts "Looking at range " + range.to_s
            unit_elements = code_elements[range]
            #pp unit_elements.map(&:class).map(&:name)
            unit_lines = unit_elements.map(&:ruby_code)
            #puts "--Checking code for code unit:"
            #pp unit_lines
            #puts "\n"
            end_index += 1
            begin
              sexp = @@parser.parse(unit_lines.join("\n"))
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
        opening.close = unit_elements.last if opening_tag_has_close
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
          opening.content = included_content
          #puts "--Now looking for code units in content:"
          #puts extract_ruby_code_elements(opening.content).map(&:to_s).join(",\n")
          #puts "---"
          find_code_units(extract_ruby_code_elements(opening.content), opening.content)
        end
      end
  end
end
