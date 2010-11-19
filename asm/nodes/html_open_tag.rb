module ERBGrammar
  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index, :content, :close

	def ==(other)
	  return false unless super(other)
      name == other.name && attributes_str == other.attributes_str &&
		(@index.nil? && other.index.nil? || @index == other.index)
	end

	def attributes
	  attrs.empty? ? [] : attrs.to_a
	end

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def eql?(other)
      return false unless other.is_a?(self.class)
	  self == other
    end

    def hash
	  h = name.hash ^ attributes_str.hash
	  h = h ^ @index.hash unless @index.nil?
	  h
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s (%d): %s %s", self.class, @index, name, attributes_str)
    end

    def pair_match?(other)
      other.is_a?(HTMLCloseTag) && name == other.name
    end

    def to_s(indent_level=0)
	  close_str = @close.nil? ? '' : @close.to_s(indent_level + 1)
	  content_str = if @content.nil?
					  "\n"
					else
					  "\n" + @content.collect do |el|
						el.to_s(indent_level + 1)
					  end.join("\n") + "\n"
					end + close_str
	  range_str = @close.nil? ? '' : sprintf("-%d", @close.index)
	  sprintf("%s%d%s: %s %s%s", Tab * indent_level, @index,
		range_str, name, attributes_str, content_str)
    end
  end
end
