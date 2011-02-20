class ComponentInteractionModel
  attr_reader :start_page, :component_expression, :atomic_sections, :transitions

  def initialize(start_page, comp_expr)
    if start_page.nil? || start_page.blank?
      raise ArgumentError, "Cannot have a nil/blank start page"
    end
    if comp_expr.nil? || comp_expr.blank?
      raise ArgumentError, "Cannot have a nil/blank component expression"
    end
    @start_page = start_page
    @component_expression = comp_expr
    @atomic_sections = []
    @transitions = []
  end

  def to_s
    sprintf("Component Interaction Model\n\tStart page: %s\n\tComponent expression: %s\n", @start_page, @component_expression)
  end
end
