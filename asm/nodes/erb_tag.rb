module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index, :content, :close, :sexp, :is_opening, :is_closing

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
      #code.text_value_removing_trims.strip
	  code.content_removing_trims
    end

    def to_s(indent_level=0)
	  close_str = @close.nil? ? '' : @close.to_s(indent_level + 1)
	  content_str = if @content.nil?
					  @is_closing ? '' : "\n"
					else
					  "\n" + @content.collect do |el|
						el.to_s(indent_level + 1)
					  end.join("\n") + "\n"
					end + close_str
	  range_str = @close.nil? ? '' : sprintf("-%d", @close.index)
	  open_close_str = @is_opening ? ' (open)' : @is_closing ? ' (close)' : ''
	  sprintf("%s%d%s%s: %s%s", Tab * indent_level, @index,
		range_str, open_close_str, ruby_code, content_str)
    end
  end
end
