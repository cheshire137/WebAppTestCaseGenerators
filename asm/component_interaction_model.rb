class ComponentInteractionModel
  attr_reader :site_root, :start_page, :component_expression, :atomic_sections, :transitions

  def initialize(root_of_site, start_page, comp_expr, sections)
    if root_of_site.nil? || root_of_site.blank?
      raise ArgumentError, "Cannot have a nil/blank site root"
    end
    if start_page.nil? || start_page.blank?
      raise ArgumentError, "Cannot have a nil/blank start page"
    end
    if comp_expr.nil? || comp_expr.blank?
      raise ArgumentError, "Cannot have a nil/blank component expression"
    end
    if sections.nil? || !sections.is_a?(Array) || sections.empty?
      raise ArgumentError, "Must give at least 1 atomic section in Array (got #{sections.class.name})"
    end
    @site_root = root_of_site.gsub(/(\/?|\\?)+$/, '')
    @start_page = start_page
    @component_expression = comp_expr
    @atomic_sections = sections
    @transitions = []
  end

  def controller
    prefix = File.join(File.join('app', 'views'), '')
    prefix_start = @start_page.index(prefix)
    return 'UNKNOWN' if prefix_start.nil?
    suffix_start = prefix_start + prefix.length
    suffix = @start_page[suffix_start...@start_page.length]
    File.dirname(suffix)
  end

  def start_url
    file_name = File.basename(@start_page.downcase)
    suffix_start = file_name.index('.')
    if suffix_start.nil?
      method = file_name
    else
      method = file_name[0...suffix_start]
    end
    sprintf("%s/%s/%s", @site_root, controller(), method)
  end

  def to_s
    sprintf("Component Interaction Model\n\tStart page: %s\n\tStart URL: %s\n\tComponent expression: %s\n", @start_page, start_url(), @component_expression)
  end
end
