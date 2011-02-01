module ERBGrammar
  class HTMLDirective < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    include SharedHTMLTagMethods
    extend SharedSexpMethods::ClassMethods

	def ==(other)
	  super(other) && prop_eql?(other, :text_value)
	end

	def hash
	  prop_hash(:text_value)
	end

    def inspect
      to_s
    end

	def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, text_value)
	end
  end
end
