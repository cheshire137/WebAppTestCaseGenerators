require 'set'
module ERBGrammar
  module SharedAtomicSectionMethods
    attr_reader :atomic_sections

    def add_atomic_section(section)
      return if section.nil?
      section_index = section.index
      if @atomic_sections.nil? || @atomic_sections.empty?
        @atomic_sections = [section]
      else
        prev_section_index = @atomic_sections.index { |s| s.index > section_index }
        if prev_section_index.nil?
          @atomic_sections << section
        else
          @atomic_sections.insert(prev_section_index, section)
        end
      end
    end

    def get_current_state
      unless respond_to?(:iteration?) && respond_to?(:aggregation?) && respond_to?(:selection?)
        return nil
      end
      if aggregation?
        :aggr
      elsif iteration?
        :iter
      elsif selection?
        :sel
      else
        nil
      end
    end

    def component_expression
      children = get_sections_and_nodes()
      child_str = children.collect do |node|
        if node.respond_to?(:component_expression)
          node.component_expression()
        else
          nil
        end
      end.compact.join('.')
      case get_current_state()
      when :iter:
        sprintf("(%s)*", child_str)
      when :sel:
        old_code = <<HERE
        puts "From perspective of " + self.to_s
        puts ''
        puts "Children:"
        pp children
        puts ''
        erb = children.select do |node|
          node.is_a?(ERBTag)
        end
        sections = children.select do |node|
          node.is_a?(AtomicSection)
        end
        #puts "ERB:"
        #pp erb
        #puts "\nAtomicSections:"
        #pp sections
        #puts ''
        if sections.empty?
        elsif 1 == sections.length
          sprintf("(%s|NULL)", sections.first.component_expression)
        else
          true_kids, false_kids = nodes_to_atomic_section_content(sections)
          #puts "True kids:"
          #pp true_kids
          #puts ''
          #puts "False kids:"
          #pp false_kids
          #puts "\n---------------"
          true_sections = content_to_atomic_sections(true_kids, sections)
          false_sections = content_to_atomic_sections(false_kids, sections)
          #puts "True sections:"
          #pp true_sections
          #puts ''
          #puts "False sections:"
          #pp false_sections
          #puts "\n******************"
          check_true_and_false_sections(true_sections, false_sections)
          true_expr = true_sections.map(&:component_expression).join('.')
          false_expr = false_sections.map(&:component_expression).join('.')
          if true_sections.empty?
            sprintf("(NULL|%s)", false_expr)
          elsif false_sections.empty?
            sprintf("(%s|NULL)", true_expr)
          else
            sprintf("(%s|%s)", true_expr, false_expr)
          end
        end
HERE
        if respond_to?(:true_content) && respond_to?(:false_content)
          if @true_content.nil? || @false_content.nil?
            "Has split branch, but no @true_content or no @false_content is set"
          else
            is_true_single = true_content.length <= 1
            is_false_single = false_content.length <= 1
            opening_true_paren = is_true_single ? '' : '('
            closing_true_paren = is_true_single ? '' : ')'
            opening_false_paren = is_false_single ? '' : '('
            closing_false_paren = is_false_single ? '' : ')'
            true_branch = case true_content.length
                          when 0
                            'NULL'
                          else
                            true_content.map(&:component_expression).join('.')
                          end
            false_branch = case false_content.length
                           when 0
                             'NULL'
                           else
                             false_content.map(&:component_expression).join('.')
                           end
            sprintf("(%s%s%s|%s%s%s)", opening_true_paren, true_branch,
                    closing_true_paren, opening_false_paren, false_branch,
                    closing_false_paren)
          end
        else
          "No split branch for " + self.class.name
        end
      when :aggr:
        if respond_to?(:atomic_section_count) && children.empty?
          sprintf("{p%s}", atomic_section_count)
        else
          sprintf("{%s}", child_str)
        end
      else
        child_str
      end
    end

    def get_sections_and_nodes(method_sym_to_call=nil, *args)
      atomic_sections_covered = []
      should_call_method = !method_sym_to_call.nil?
      details = (@atomic_sections || []) + (@content || [])
      details.sort! do |a, b|
        comparison = a.range <=> b.range
        equal = 0 == comparison
        a_atomic = a.is_a?(AtomicSection)
        b_atomic = b.is_a?(AtomicSection)
        # Sort AtomicSections first so we don't end up repeating nodes that are
        # accounted for in an AtomicSection
        if equal && a_atomic && !b_atomic
          -1
        elsif equal && !a_atomic && b_atomic
          1
        else
          comparison
        end
      end
      details.collect do |section_or_node|
        cur_range = section_or_node.range
        if atomic_sections_covered.include?(cur_range.begin)# && !section_or_node.is_a?(AtomicSection)
          nil
        else
          atomic_sections_covered += cur_range.to_a
          if should_call_method
            section_or_node.send(method_sym_to_call, *args)
          else
            section_or_node
          end
        end
      end.compact
    end

    def nest_atomic_sections
      code_units = @content.select do |el|
        "ERBGrammar::ERBTag" == el.class.name && !el.content.nil? && !el.content.empty?
      end
      return if code_units.empty?
      (@atomic_sections.length-1).downto(0) do |i|
        section = @atomic_sections[i]
        section_range = section.range
        parent_code = code_units.find do |code_unit|
          code_range = code_unit.range
          code_range.include?(section_range.begin) &&
            code_range.include?(section_range.end)
        end
        unless parent_code.nil?
          parent_code.add_atomic_section(section)
          @atomic_sections.delete_at(i)
          parent_code.nest_atomic_sections
        end
      end
    end

    def split_branches
      branch_processor = lambda do |child|
        if child.respond_to?(:split_branch) && child.respond_to?(:selection?) && child.selection?
          child.split_branch()
        end
      end
      if is_a?(ERBDocument)
        each(&branch_processor)
      else
        # TODO: should I split innermost branches first, to get nested if's?
        # Thus should I do branch_processor on @content before self?
        branch_processor.call(self)
        @content.each(&branch_processor)
      end
    end

    private
      def nodes_to_atomic_section_content(sections)
        child_section_erb = sections.collect do |section|
          if section.content.nil? || section.content.length < 1
            next
          end
          code_lines = section.content.map(&:text_value)
          FakeERBOutput.new(code_lines, section.content.first.index)
        end.compact
        true_kids = child_section_erb.select do |node|
          selection_true_case?(node.sexp)
        end
        false_kids = child_section_erb.select do |node|
          selection_false_case?(node.sexp)
        end
        [true_kids, false_kids]
      end

      def check_true_and_false_sections(true_sections, false_sections)
        true_set = Set.new(true_sections)
        false_set = Set.new(false_sections)
        true_and_false_sections = true_set.intersection(false_set)
        unless true_and_false_sections.empty?
          raise RuntimeError, "Should not have the same AtomicSection(s) in " +
            "both the true and false branch of selection:\n" +
            true_and_false_sections.to_a.map(&:to_s).join(', ')
        end
      end

      def content_to_atomic_sections(content, atomic_sections)
        content.collect do |node|
          atomic_sections.select do |section|
            section.is_a?(AtomicSection) && section.include?(node)
          end.first
        end.compact.uniq
      end
  end
end
