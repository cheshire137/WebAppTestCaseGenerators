module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
	include SharedERBMethods
	include SharedOpenTagMethods
    attr_accessor :content, :close, :sexp

	def inspect
	  sprintf("%s (%d): %s\n%s", self.class, @index, ruby_code, content_str())
	end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level,
		sprintf("%s\n%s", ruby_code, content_str(indent_level+1)))
    end
  end
end
