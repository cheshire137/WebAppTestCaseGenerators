require File.join('nodes', 'fake_erb_output.rb')
class AtomicSection
  include SharedMethods
  include SharedSexpParsing
  include SharedSexpMethods
  extend SharedSexpMethods::ClassMethods
  attr_reader :content, :count, :index

  def initialize(count=1)
	@content = []
	@count = count
    @index = -1
  end

  def can_add_node?(node)
    return false if node.nil?
    return false unless node.browser_output?
    return false if node.index.nil?
    return true if @content.empty?
    last_node = @content.last
	last_node.same_atomic_section?(node) && last_node != node
  end

  def component_expression
    default_expr = sprintf("p%d", @count)
    unless @content.nil? || @content.empty?
      child_str = @content.collect do |node|
        if node.respond_to?(:component_expression)
          node.component_expression()
        else
          nil
        end
      end.compact.join('.')
      return child_str unless child_str.blank?
    end
    default_expr
  end

  def include?(node)
    return false if @content.nil? || @content.empty?
    return false if node.nil?
    if node.is_a?(ERBGrammar::FakeERBOutput)
      ERBGrammar::FakeERBOutput.new(@content.map(&:text_value), @index) == node
    else
      @content.include?(node)
    end
  end

  def inspect
    to_s
  end

  def range
    return nil if @content.nil? || @content.empty?
    @content.sort! do |a, b|
      a.index <=> b.index
    end
    start_index = @content.first.index
    end_index = @content.last.index
    if start_index.nil? || end_index.nil?
      raise RuntimeError, "Nil start or end index; atomic section has content: " + @content.inspect
    end
    (start_index..end_index)
  end

  # TODO: remove duplication between this and SharedHTMLTagMethods
  def ruby_code
    @content.collect do |child|
      'puts "' + child.text_value.gsub(/"/, "\\\"") + '"'
    end.join("\n")
  end

  def save(file_path)
    File.open(file_path, 'w') do |file|
      @content.each do |node|
        file.puts node.text_value
      end
    end
  end

  def to_s(indent_level=0)
	to_s_with_prefix(indent_level, sprintf("Atomic Section #%d (indices %s):\n%s",
      @count,
      range().to_s,
      @content.collect do |node|
        node.to_s(indent_level+1)
      end.join("\n")))
  end

  def try_add_node?(node)
	if can_add_node?(node)
      @index = node.index if @content.empty?
	  @content << node
      if node.respond_to?(:atomic_section_count)
        node.atomic_section_count = @count
      end
	  true
	else
	  false
	end
  end
end
