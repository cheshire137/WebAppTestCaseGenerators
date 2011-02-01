module ERBGrammar
  class Text < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods

	def ==(other)
	  super(other) && prop_eql?(other, :text_value)
	end

	def hash
	  prop_hash(:text_value)
	end

    # TODO: remove duplication between this and SharedHTMLTagMethods
    def ruby_code
      'puts "' + text_value.gsub(/"/, "\\\"") + '"'
    end

    def to_s(indent_level=0)
      stripped = text_value.strip
      to_s_with_prefix(
        indent_level, 
		if stripped.empty?
		  ''
		else
		  stripped.gsub(/\'/, "\\\\'")
		end
	  )
    end
  end
end
