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
                    raise "How does ERBTag #{to_s} have nested atomic sections if it is " +
                      "not iteration, selection, or aggregation?"
                  end
    else
      cur_state = nil
    end
    child_expr = get_sections_and_nodes().select do |node|
      node.respond_to?(:component_expression)
    end.collect do |node|
      node.component_expression(cur_state).gsub(/\(\|/, '|').gsub(/\|\(/, ')(').gsub(/\.\|\./, '|')
    end.join('.')
    case cur_state
      when :iter:
        sprintf("(%s)*", child_expr)
      when :sel:
        sprintf("(%s|", child_expr)
      when :aggr:
        # TODO: yield/render stuff handled differently?
        sprintf("(___{%s})", child_expr)
      else
        child_expr.gsub(/\|\./, ').')
    end
  end

  def get_sections_and_nodes(method_sym_to_call=nil)
    atomic_sections_covered = []
    should_call_method = !method_sym_to_call.nil?
    details = (@atomic_sections || []) + (@content || [])
    details.sort! { |a, b| a.range <=> b.range }
    details.collect do |section_or_node|
      cur_range = section_or_node.range
      if atomic_sections_covered.include?(cur_range.begin)
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
