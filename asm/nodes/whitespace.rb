module ERBGrammar
  class Whitespace < Treetop::Runtime::SyntaxNode
	attr_accessor :index

	def to_s
	  ''
	end
  end
end
