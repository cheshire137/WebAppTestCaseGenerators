module ERBGrammar
  class RubyCode < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
      content_removing_trims == other.content_removing_trims
	end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
      content_removing_trims.hash
    end

    def content_removing_trims
      text_value.strip.gsub(/\s*\-\s*$/, '')
    end

    def to_s(indent_level=0)
      Tab * indent_level + result
    end
  end
end
