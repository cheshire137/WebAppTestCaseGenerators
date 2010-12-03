module ERBGrammar
  class ERBYield < Treetop::Runtime::SyntaxNode
    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, 'yield')
    end
  end
end
