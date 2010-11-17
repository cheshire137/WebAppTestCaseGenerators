module ERBGrammar
  class Treetop::Runtime::SyntaxNode
    include Enumerable

	def [](obj)
	  if obj.is_a?(Fixnum)
		each_with_index do |el, i|
		  return el if i == obj
		end
	  end
	end

	def ==(other)
      return false unless other.is_a?(self.class)
	  return false unless length == other.length
	  if nonterminal?
		elements.each_with_index do |el, i|
		  return false unless el == other[i]
		end
	  end
	  true
	end

	def each
	  if nonterminal?
		elements.each { |el| yield el }
	  end
	end

	def length
	  nonterminal? ? elements.length : 0
	end

	# Thanks to https://github.com/aarongough/koi-reference-parser/blob/
	# development/lib/parser/syntax_node_extensions.rb
    def to_h
      hash = {}
      hash[:offset] = interval.first
      hash[:text_value] = text_value
      hash[:name] = self.class.name.split("::").last
      if elements.nil?
        hash[:elements] = nil
      else
        hash[:elements] = elements.map do |element|
          element.to_h
        end
      end
      hash
    end
  end
end
