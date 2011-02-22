module ERBGrammar
  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
	include SharedOpenTagMethods
	include SharedHTMLTagMethods
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedTransitionMethods
    attr_accessor :content, :close

	def ==(other)
	  super(other) && prop_eql?(other, :name, :attributes_str)
	end

	def attributes
	  attrs.empty? ? [] : attrs.to_a
	end

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def get_local_transitions(source)
      trans = []
      tag_name = name()
      # TODO: fill in correct sink
      if 'form' == tag_name
        trans << FormTransition.new(source, 'placeholder for sink', text_value)
      elsif 'a' == tag_name
        trans << LinkTransition.new(source, 'placeholder for sink', text_value)
      end
      trans
    end

    def hash
	  prop_hash(:name, :attributes_str)
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s (%d): %s %s", self.class, @index, name, attributes_str)
    end

    def pair_match?(other)
	  opposite_type_same_name?(HTMLCloseTag, other)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, sprintf("%s %s\n%s",
		name, attributes_str, content_str(indent_level+1)))
    end
  end
end
