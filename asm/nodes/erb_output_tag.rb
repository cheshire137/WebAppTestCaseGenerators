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
      sprintf("%s (%d): %s", self.class, @index, ruby_code)
    end

    def ruby_code
      code.content_removing_trims
    end

    def to_s(indent_level=0)
      sprintf("%s%d: %s", Tab * indent_level, @index, ruby_code)
    end
  end
end
