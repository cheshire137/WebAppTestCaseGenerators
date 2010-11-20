module ERBGrammar
  class Whitespace < Treetop::Runtime::SyntaxNode
	def to_s(indent_level=0)
      to_s_with_prefix(indent_level)
	end
  end
end
