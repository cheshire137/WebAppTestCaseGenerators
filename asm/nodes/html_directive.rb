module ERBGrammar
  class HTMLDirective < Treetop::Runtime::SyntaxNode
	def ==(other)
	  super(other) && prop_eql?(other, :text_value)
	end

	def hash
	  prop_hash(:text_value)
	end

	def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, text_value)
	end
  end
end
