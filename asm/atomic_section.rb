class AtomicSection
  include SharedMethods
  attr_reader :nodes, :count, :index

  def initialize(count=1)
	@nodes = []
	@count = count
    @index = -1
  end

  def can_add_node?(node)
    return false if node.nil?
    return false unless node.browser_output?
    return true if @nodes.empty?
    last_node = @nodes.last
	last_node.same_atomic_section?(node) && last_node != node
  end

  def component_expression(prev_state=nil)
    sprintf("p%d", @count)
  end

  def range
    return nil if @nodes.nil? || @nodes.empty?
    @nodes.sort! do |a, b|
      a.index <=> b.index
    end
    start_index = @nodes.first.index
    end_index = @nodes.last.index
    (start_index..end_index)
  end

  def save(file_path)
    File.open(file_path, 'w') do |file|
      @nodes.each do |node|
        file.puts node.text_value
      end
    end
  end

  def to_s(indent_level=0)
	to_s_with_prefix(indent_level, sprintf("Atomic Section #%d (indices %s):\n%s",
      @count,
      range().to_s,
      @nodes.collect do |node|
        node.to_s(indent_level+1)
      end.join("\n")))
  end

  def try_add_node?(node)
	if can_add_node?(node)
      @index = node.index if @nodes.empty?
	  @nodes << node
	  true
	else
	  false
	end
  end
end
