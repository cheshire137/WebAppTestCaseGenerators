module ERBGrammar
  class HTMLDirective < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
      text_value == other.text_value && (@index.nil? && other.index.nil? || @index == other.index)
	end

	def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
	end

	def hash
	  h = text_value.hash
	  h = h ^ @index.hash unless @index.nil?
	  h
	end

	def to_s(indent_level=0)
	  sprintf("%s%d: %s", Tab * indent_level, @index, text_value)
	end
  end
end
