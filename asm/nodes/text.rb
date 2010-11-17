module ERBGrammar
  class Text < Treetop::Runtime::SyntaxNode
    attr_accessor :index

	def ==(other)
	  return false unless super(other)
	  text_value == other.text_value
	end

	def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
	end

	def hash
	  text_value.hash
	end

    def to_s
      stripped = text_value.strip
      sprintf(
		"%d: %s", @index,
		if stripped.empty?
		  ''
		else
		  stripped.gsub(/\'/, "\\\\'")
		end
	  )
    end
  end
end
