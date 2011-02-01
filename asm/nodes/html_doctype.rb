module ERBGrammar
  class HTMLDoctype < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    include SharedHTMLTagMethods
    extend SharedSexpMethods::ClassMethods

	def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, text_value)
	end
  end
end
