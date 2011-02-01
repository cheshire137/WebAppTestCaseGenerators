module ERBGrammar
  class HTMLTagAttributes < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  return false unless super(other) && index_eql?(other)
	  this_arr = to_a
      other_arr = other.to_a
      return false if this_arr.length != other_arr.length
      this_arr.each_with_index do |el, i|
        return false unless el == other_arr[i]
      end
	  true
	end

    def hash
      h = prop_hash()
      to_a.each do |el|
        h = h ^ el.hash
      end
      h
    end

    def to_a
      arr = [head]
      unless tail.empty?
        arr += tail.elements.first.to_a
      end
      arr
    end

    def to_h
      hash = {}
      hash[head.name] = head.value
      unless tail.empty?
        hash.merge!(tail.elements.first.to_h)
      end
      hash
    end

    def to_s(indent_level=0)
      to_a.map(&:to_s).join(', ')
    end
  end
end
