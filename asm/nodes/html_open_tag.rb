module ERBGrammar
  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index, :content, :close

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
      sprintf("%s (%d): %s %s", self.class, @index, name, attributes_str)
    end

    def pair_match?(other)
      other.is_a?(HTMLCloseTag) && name == other.name
    end

    def to_s(indent_level=0)
	  sprintf("%s%d%s: %s%s%s", Tab * indent_level, @index,
		@close.nil? ? '' : sprintf("-%d", @close.index),
		name, attributes.length > 0 ? sprintf(" %s", attributes_str) : '',
		@content.nil? ? '' : sprintf("\n%s--%s", Tab * (indent_level+1), @content.to_s))
    end
  end
end
