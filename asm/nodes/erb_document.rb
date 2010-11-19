module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
	include Enumerable
	attr_reader :nodes, :initialized_nodes

	def [](obj)
	  if obj.is_a?(Fixnum)
		each_with_index do |el, i|
		  return el if el.index == obj || i == obj
		end
	  elsif obj.respond_to?(:include?)
		i = 0
		select do |el|
		  index_match = !el.index.nil? && obj.include?(el.index)
		  i_match = el.index.nil? && obj.include?(i)
		  result = index_match || i_match
		  i += 1
		  result
		end
	  else
		nil
	  end
	end

	def compress_content
	  (length-1).downto(0) do |i|
		element = self[i]
		next unless element.respond_to?(:pair_match?) &&
					element.respond_to?(:close) &&
					!element.close.nil?
		# element is open tag
		range = element.index+1...element.close.index
		content = self[range].compact
		unless content.nil? || content.empty?
		  element.content = content.dup 
		  content.each do |consumed_el|
			@nodes.delete(consumed_el)
		  end
		  # Closing element is not part of the content, but it no longer
		  # needs to appear as a separate element in the tree
		  @nodes.delete(element.close)
		end
	  end
	end

	def each
	  if @initialized_nodes
		@nodes.each { |n| yield n }
	  else
		yield node
		if !x.nil? && x.respond_to?(:each)
		  x.each { |other| yield other }
		end
	  end
	end

    def inspect
      to_s
    end

	# Returns the number of HTML, ERB, and text nodes in this document
	def length
	  if @initialized_nodes
		@nodes.length
	  else
		1 + (x.respond_to?(:length) ? x.length : 0)
	  end
	end

    def pair_tags
	  @initialized_nodes = false
	  @nodes = []
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :index
		@nodes << element
        element.index = i
        next unless element.respond_to? :pair_match?
        # Find first matching mate for this element in the array of mateless
        # elements.  First matching mate will be latest added element.
        mate = mateless.find { |el| el.pair_match?(element) }
        if mate.nil?
          # Add mate to beginning of mateless array, so array is sorted by
          # most-recently-found to earliest-found.
          mateless.insert(0, element)
        else
          if mate.respond_to? :close
            mate.close = element
            mateless.delete(mate)
          else
            raise "Mate found out of order: " + mate.to_s + ", " + element.to_s
          end
        end
      end
	  @initialized_nodes = true
    end

    def to_s(indent_level=0)
	  (Tab * indent_level) + map(&:to_s).select { |str| !str.blank? }.join("\n")
    end
  end
end
