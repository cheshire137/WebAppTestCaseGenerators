module ERBGrammar
  class HTMLTagAttribute < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  super(other) && prop_eql?(other, :name, :value)
	end

    def hash
	  prop_hash(:name, :value)
    end

    def name
	  n.text_value.downcase
    end

    def value
      v.text_value
    end

    def inspect
      sprintf("%s: %s => %s", self.class, name, value)
    end

    def to_s(indent_level=0)
	  sprintf("%s => %s", name, value)
    end
  end
end
