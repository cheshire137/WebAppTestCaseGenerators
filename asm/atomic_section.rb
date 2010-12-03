class AtomicSection
  attr_reader :nodes, :count

  def initialize(count=1)
	@nodes = []
	@count = count
  end

  def can_add_node?(node)
    return true if @nodes.empty?
    last_node = @nodes.last
	last_node.same_atomic_section?(node) && last_node != node
  end

  def to_s
	sprintf("Atomic Section #%d:\n%s",
      @count,
      @nodes.collect do |node|
        node.to_s(1)
      end.join("\n"))
  end

  def try_add_node?(node)
	if can_add_node?(node)
	  @nodes << node
	  true
	else
	  false
	end
  end
end
