module ERBGrammar
  class Text < Treetop::Runtime::SyntaxNode
    attr_accessor :index

    def to_s
      stripped = text_value.strip
      sprintf(
		"%d: %s", @index,
		if stripped.empty?
		  ''
		else
		  stripped.gsub(/\'/, "\\\\'")
		end
	  )
    end
  end
end
