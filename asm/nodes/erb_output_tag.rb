module ERBGrammar
  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index
    def eql?(other)
      return false unless other.is_a?(self.class)
      code == other.code
    end
    def hash
      code.hash
    end
    def inspect
      sprintf("%s: %s", self.class, ruby_code)
    end
    def ruby_code
      code.content_removing_trims
    end
    def to_s(indent_level=0)
      Tab * indent_level + ruby_code
    end
  end
end
