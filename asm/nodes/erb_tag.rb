module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
	  code == other.code && (@index.nil? && other.index.nil? || @index == other.index)
	end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
      h = code.hash
	  h = h ^ @index.hash unless @index.nil?
	  h
    end

    def inspect
      sprintf("%s (%d): %s", self.class, @index, ruby_code)
    end

    def ruby_code
      code.text_value_removing_trims.strip
    end

    def to_s(indent_level=0)
      sprintf("%s%d: <%s %s %s>", Tab * indent_level, @index, '%', ruby_code,
		'%')
    end
  end
end
