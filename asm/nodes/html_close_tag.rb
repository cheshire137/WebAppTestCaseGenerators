module ERBGrammar
  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
	  name == other.name && (@index.nil? && other.index.nil? || @index == other.index)
	end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
      h = name.hash
	  h = h ^ @index.hash unless @index.nil?
	  h
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s %d: %s", self.class, @index, name)
    end

    def pair_match?(other)
      other.is_a?(HTMLOpenTag) && name == other.name
    end

    def to_s(indent_level=0)
      sprintf("%s%d: /%s", Tab * indent_level, @index, name)
    end
  end
end
