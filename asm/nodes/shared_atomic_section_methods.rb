require 'set'
module ERBGrammar
  module SharedAtomicSectionMethods
    module ClassMethods
      def section_and_node_sort(a, b)
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
    end
    attr_reader :atomic_sections

    def add_atomic_section(section)
      return if section.nil?
      section_index = section.index
      if section_index <= @index
        raise ArgumentError, "Cannot set section #{section} to be child of #{self}--index is too low"
      end
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

    def get_code_units_for_nesting
      @content.select do |el|
        "ERBGrammar::ERBTag" == el.class.name && !el.content.nil? && !el.content.empty?
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

    def component_expression(seen_children=[])
      cur_state = get_current_state()
      seen_children << self unless seen_children.include?(self)
      if :sel == cur_state
        expr = selection_component_expression(seen_children)
        return expr
      end
      children = get_sections_and_nodes()
      child_str = children.collect do |node|
        if node.respond_to?(:component_expression) && !seen_children.include?(node)
          seen_children << node
          node.component_expression(seen_children)
        else
          nil
        end
      end.compact.select do |expr|
        !expr.blank?
      end.join('.')
      case cur_state
        when :iter:
          if child_str.nil? || child_str.blank?
            nil
          else
            has_single_child = (1 == children.length)
            open_paren = has_single_child ? '' : '('
            close_paren = has_single_child ? '' : ')'
            sprintf("%s%s%s*", open_paren, child_str, close_paren)
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
      details.sort! { |a, b| self.class.section_and_node_sort(a, b) }
      details.collect do |section_or_node|
        cur_range = section_or_node.range
        if atomic_sections_covered.include?(cur_range.begin)
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
      code_units = get_code_units_for_nesting()
      return if code_units.empty?
      reversed_code_units = code_units.reverse
      (@atomic_sections.length-1).downto(0) do |i|
        section = @atomic_sections[i]
        section_range = section.range
        find_parent_code = lambda do |code_unit|
          code_range = code_unit.range
          code_range.include?(section_range.begin) &&
            code_range.include?(section_range.end)
        end
        parent_code = code_units.find(&find_parent_code)
        unless parent_code.nil?
          # Maybe the parent has another child that should actually be
          # the parent of this atomic section
          #parent_code_units = parent_code.get_code_units_for_nesting()
          #if parent_code_units.length > 0
          #  parent_code = parent_code_units.find(&find_parent_code) || parent_code
          #end
          #puts "Adding atomic section"
          #puts section.to_s
          #puts "To parent"
          #puts parent_code.to_s
          #puts ''
          parent_code.add_atomic_section(section)
          @atomic_sections.delete_at(i)
          parent_code.nest_atomic_sections()
        end
      end
    end

    def split_branches
      # TODO: should I split innermost branches first, to get nested if's?
      # Thus should I do branch_processor on @content before self?
      if respond_to?(:split_branch) && respond_to?(:selection?) && selection?
        split_branch()
      end
      (@content || []).select do |child|
        !child.nil? && child.respond_to?(:split_branches)
      end.each do |child|
        child.split_branches()
      end
      if !@close.nil? && @close.respond_to?(:split_branches)
        @close.split_branches()
      end
    end

    private
      def selection_component_expression(seen_children=[])
        if !respond_to?(:branch_content)
          # End up here when, for example, there's an if statement within an ERBOutputTag,
          # e.g., <%= (user.id == session[:user][:id]) ? 'you' : user.email %>
          return nil
        end
        if @branch_content.nil?
          return "Has split branch, but no @branch_content is set"
        end
        child_selector = lambda do |n|
                            if seen_children.include?(n) || !n.respond_to?(:component_expression)
                              nil
                            else
                              seen_children << n
                              n.component_expression(seen_children)
                            end
                          end
        branches_exprs = @branch_content.collect do |cur_branch_content|
          if cur_branch_content.nil? || cur_branch_content.empty?
            nil
          else
            cur_branch_exprs = cur_branch_content.map(&child_selector).compact.select do |expr|
              !expr.blank?
            end
            if cur_branch_exprs.empty?
              nil
            else
              cur_branch_str = cur_branch_exprs.join('.')
              one_child = cur_branch_exprs.length == 1
              open_paren = one_child ? '' : '('
              close_paren = one_child ? '' : ')'
              sprintf("%s%s%s", open_paren, cur_branch_str, close_paren)
            end
          end
        end.compact
        return nil if branches_exprs.empty?
        if branches_exprs.length == 1
          branches_exprs << 'NULL'
        end
        branches_str = branches_exprs.join('|')
        branches_str = 'NULL' if branches_str.blank?
        sprintf("(%s)", branches_str)
      end

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
