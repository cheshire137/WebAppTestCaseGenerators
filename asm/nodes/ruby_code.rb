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
      result.gsub(/\s*\-\s*$/, '')
    end

    def text_value_removing_trims
      text_value.gsub(/\s*\-\s*$/, '')
    end

    def result
      code = text_value.strip
      # matches a word, followed by either a word, a string, or a symbol
      code.gsub(/^(\w+) ([\w:"'].*)$/, '\1(\2)')
    end

    def to_s(indent_level=0)
      Tab * indent_level + result
    end
  end
end
