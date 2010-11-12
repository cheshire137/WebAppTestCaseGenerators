module ERBGrammar
  class HTMLTagAttribute < Treetop::Runtime::SyntaxNode
    attr_accessor :index
    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name && value == other.value
    end
    def hash
      name.hash ^ value.hash
    end
    def name
      (n.text_value =~ /[-:]/) ? "'#{n.text_value}'" : ":#{n.text_value}"
    end
    def value
      v.text_value
    end
    def inspect
      sprintf("%s: %s => %s", self.class, name, value)
    end
    def to_s(indent_level=0)
      Tab * indent_level + sprintf("%s => %s", name, value)
    end
  end
end
