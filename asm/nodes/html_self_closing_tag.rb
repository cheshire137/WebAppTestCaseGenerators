module ERBGrammar
  class HTMLSelfClosingTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
      name == other.name && attributes_str == other.attributes_str
	end

	def attributes
	  attrs.empty? ? [] : attrs.to_a
	end

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
      name.hash ^ attributes_str.hash
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s: %s %s", self.class, name, attributes_str)
    end

    def to_s(indent_level=0)
      Tab * indent_level + sprintf("%s %s", name, attributes_str)
    end
  end
end
