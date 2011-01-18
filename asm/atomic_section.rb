class AtomicSection
  include SharedMethods
  attr_reader :content, :count, :index

  def initialize(count=1)
	@content = []
	@count = count
    @index = -1
  end

  def can_add_node?(node)
    return false if node.nil?
    return false unless node.browser_output?
    return true if @content.empty?
    last_node = @content.last
	last_node.same_atomic_section?(node) && last_node != node
  end

  def component_expression
    sprintf("p%d", @count)
  end

  def range
    return nil if @content.nil? || @content.empty?
    @content.sort! do |a, b|
      a.index <=> b.index
    end
    start_index = @content.first.index
    end_index = @content.last.index
    (start_index..end_index)
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
	  true
	else
	  false
	end
  end
end
