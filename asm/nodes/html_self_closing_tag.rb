module ERBGrammar
  class HTMLSelfClosingTag < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  super(other) && prop_eql?(other, :name, :attributes_str)
	end

	def attributes
	  attrs.empty? ? [] : attrs.to_a
	end

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def hash
	  prop_hash(:name, :attributes_str)
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s: %s %s", self.class, name, attributes_str)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, name + ' ' + attributes_str)
    end
  end
end
