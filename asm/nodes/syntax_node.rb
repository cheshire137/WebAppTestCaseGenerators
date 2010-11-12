module ERBGrammar
  class Treetop::Runtime::SyntaxNode
    include Enumerable

	def each
	  if nonterminal?
		elements.each { |el| yield el }
	  end
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
