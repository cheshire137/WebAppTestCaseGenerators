module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
	include Enumerable

	def compress_content
	  indices_consumed = []
	  each_with_index do |element, i|
		next unless element.respond_to? :index
		if element.respond_to? :pair_match?
		  unless indices_consumed.include? element.index
			if element.respond_to?(:close) && !element.close.nil?
			  # element is open tag
			  range = element.index+1...element.close.index
			  element.content = self[range]
			  indices_consumed += range.to_a
			  # Closing element is not part of the content, but it no longer
			  # needs to appear as a separate element in the tree
			  indices_consumed << element.close.index
			end
		  end
		end
		if indices_consumed.include? element.index
		  delete_at(i)
		end
	  end
	end

	def each
	  yield node
	  if !x.nil? && x.respond_to?(:each)
		x.each { |other| yield other }
	  end
	end

    def inspect
      to_s
    end

    def pair_tags
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :index
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
    end

    def to_s
	  map(&:to_s).select { |str| !str.blank? }.join("\n")
    end
  end
end
