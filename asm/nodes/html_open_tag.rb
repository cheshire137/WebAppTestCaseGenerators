module ERBGrammar
  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index, :content, :close

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name && attributes_str == other.attributes_str
    end

    def hash
      name.hash ^ attributes_str.hash
    end

    def name
      tag_name.text_value
    end

    def inspect
      sprintf("%s (%d): %s %s", self.class, @index, name, attributes_str)
    end

    def pair_match?(other)
      other.is_a?(HTMLCloseTag) && name == other.name
    end

    def to_s(indent_level=0)
	  sprintf("%s%d%s: %s", Tab * indent_level, @index,
		@close.nil? ? '' : sprintf("-%d", @close.index),
		name)
    end
  end
end
