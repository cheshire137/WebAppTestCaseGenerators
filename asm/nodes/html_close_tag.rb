module ERBGrammar
  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
	include SharedHTMLTagMethods

	def ==(other)
	  super(other) && prop_eql?(other, :name)
	end

    def hash
	  prop_hash(:name)
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s %d: %s", self.class, @index, name)
    end

    def pair_match?(other)
	  opposite_type_same_name?(HTMLOpenTag, other)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, '/' + name)
    end
  end
end
