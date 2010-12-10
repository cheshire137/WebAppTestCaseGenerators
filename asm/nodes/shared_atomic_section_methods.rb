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

  def get_sections_and_nodes(method_sym_to_call=nil)
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
      if atomic_sections_covered.include?(cur_range.begin) && !section_or_node.is_a?(AtomicSection)
        nil
      else
        atomic_sections_covered += cur_range.to_a
        if should_call_method
          section_or_node.send(method_sym_to_call)
        else
          section_or_node
        end
      end
    end.compact
  end
end
