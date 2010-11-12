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
      sprintf("%s %d: %s %s", self.class, @index, name, attributes_str)
    end
    def pair_match?(other)
      other.is_a?(HTMLCloseTag) && name == other.name
    end
    def to_s(indent_level=0)
      str = sprintf("%s%s %s", Tab * indent_level, name, attributes_str)
      unless @content.nil?
        str << sprintf("\n--%s%s", Tab * (indent_level + 1), @content)
      end
      unless @close.nil?
        str << sprintf("\n--%s%s", Tab * indent_level, @close)
      end
      str
    end
  end
end
