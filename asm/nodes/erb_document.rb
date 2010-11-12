module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
	include Enumerable

	def [](obj)
	  if obj.is_a?(Fixnum)
		each_with_index do |el, i|
		  return el if el.index == obj || i == obj
		end
	  elsif obj.is_a?(Range)
		i = 0
		select do |el|
		  result = obj.include?(el.index) || obj.include?(i)
		  i += 1
		  result
		end
	  end
	  nil
	end

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

	def delete_at(index)
	  unless index.is_a?(Fixnum)
		raise ArgumentError, "Given index must be a Fixnum"
	  end
	  len = length
	  if index < 0 || index >= length
		raise ArgumentError, sprintf("Given index %d is invalid--must be between 0 <= index < %d", len)
	  end
	  obj = self[index]
	  if node.index == index || 0 == index
		if x.nil? || x.empty?
		  node = nil
		else
		  node = x.shift
		end
	  else
		i = 0
		x = x.collect do |el|
		  result = if el.index == index || i == index
			nil
		  else
			el
		  end
		  i += 1
		  result
		end.compact
	  end
	  obj
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

	def length
	  1 + (x.respond_to?(:length) ? x.length : 0)
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
