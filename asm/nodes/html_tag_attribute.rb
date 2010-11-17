module ERBGrammar
  class HTMLTagAttribute < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
      name == other.name && value == other.value
	end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
      name.hash ^ value.hash
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
      sprintf("%s%s => %s", Tab * indent_level, name, value)
    end
  end
end
