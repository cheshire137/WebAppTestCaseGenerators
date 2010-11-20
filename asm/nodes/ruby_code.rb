module ERBGrammar
  class RubyCode < Treetop::Runtime::SyntaxNode
	def ==(other)
	  super(other) && prop_eql?(other, :content_removing_trims)
	end

    def hash
	  prop_hash(:content_removing_trims)
    end

    def content_removing_trims
      text_value.strip.gsub(/\s*\-\s*$/, '')
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level, result)
    end
  end
end
