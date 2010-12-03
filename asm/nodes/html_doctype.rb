module ERBGrammar
  class HTMLDoctype < Treetop::Runtime::SyntaxNode
	def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, text_value)
	end
  end
end
