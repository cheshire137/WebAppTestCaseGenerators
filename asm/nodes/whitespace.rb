module ERBGrammar
  class Whitespace < Treetop::Runtime::SyntaxNode
	attr_accessor :index

	def to_s(indent_level=0)
	  Tab * indent_level
	end
  end
end
