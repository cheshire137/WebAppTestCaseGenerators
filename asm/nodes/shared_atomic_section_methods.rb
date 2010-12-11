module SharedAtomicSectionMethods
  attr_reader :atomic_sections

  def component_expression(prev_state=nil)
    if self.class.name == "ERBGrammar::ERBTag"
      cur_state = if iteration?
                    :iter
                  elsif selection?
                    :sel
                  elsif aggregation?
                    :aggr
                  else
                    nil
                  end
    else
      cur_state = nil
    end
    child_expr = get_sections_and_nodes().select do |node|
      node.respond_to?(:component_expression)
    end.collect do |node|
      node.component_expression(cur_state).gsub(/\(\|/, '|').gsub(/\|\(/, ')(').gsub(/\.\|\./, '|')
    end.select { |expr| !expr.blank? }.join('.')
    case cur_state
      when :iter:
        sprintf("(%s)*", child_expr)
      when :sel:
        sprintf("(%s|", child_expr)
      when :aggr:
        # TODO: yield/render stuff handled differently?
        sprintf("(___{%s})", child_expr)
      else
        child_expr.gsub(/\|\./, ').').gsub(/\|$/, ')')
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
end
