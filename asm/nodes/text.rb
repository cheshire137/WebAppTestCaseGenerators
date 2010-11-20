module ERBGrammar
  class Text < Treetop::Runtime::SyntaxNode
	def ==(other)
	  super(other) && prop_eql?(other, :text_value)
	end

	def hash
	  prop_hash(:text_value)
	end

    def to_s(indent_level=0)
      stripped = text_value.strip
      to_s_with_prefix(indent_level, 
		if stripped.empty?
		  ''
		else
		  stripped.gsub(/\'/, "\\\\'")
		end
	  )
    end
  end
end
