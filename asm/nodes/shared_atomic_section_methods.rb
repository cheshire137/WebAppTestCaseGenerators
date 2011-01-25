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

    def nodes_to_atomic_section_content(sections)
      child_atom_sec_erb = sections.map(&:content).flatten.collect do |node|
        if node.respond_to?(:sexp)
          node
        else
          FakeERBOutput.new(node)
        end
      end
      true_kids = child_atom_sec_erb.select do |node|
        selection_true_case?(node.sexp)
      end
      false_kids = child_atom_sec_erb.select do |node|
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
        sections = children.select do |node|
          node.is_a?(AtomicSection)
        end
        true_kids, false_kids = nodes_to_atomic_section_content(sections)
        true_sections = content_to_atomic_sections(true_kids, sections)
        false_sections = content_to_atomic_sections(false_kids, sections)
        puts "True kids:"
        pp true_kids
        puts ''
        puts "True kids atomic sections:"
        pp true_sections
        puts ''
        puts ''
        puts "False kids:"
        pp false_kids
        puts ''
        puts "False kids atomic sections:"
        pp false_sections
        puts ''
        check_true_and_false_sections(true_sections, false_sections)
        'sel'
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

    def get_selection_component_expression(children)
      return '' if children.nil? || children.empty?
  #    puts "Selection with children:"
      section_exprs = children.select do |child|
        child.respond_to?(:component_expression)
      end.map(&:component_expression).select do |expr|
        !expr.blank?
      end
  #    pp section_exprs
      if section_exprs.length < 2
        section_exprs << 'NULL'
      end
      '(' + section_exprs.join('|') + ')'
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
  end
end
