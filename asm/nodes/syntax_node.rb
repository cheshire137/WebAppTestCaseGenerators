module ERBGrammar
  class Treetop::Runtime::SyntaxNode
    include Enumerable
    include SharedMethods
    PlainHTMLTypes = [HTMLDirective, HTMLOpenTag, HTMLCloseTag, Whitespace, Text, HTMLDoctype, HTMLQuotedValue, HTMLSelfClosingTag, HTMLTagAttribute].freeze
    BrowserOutputTypes = (PlainHTMLTypes + [ERBOutputTag]).freeze
    RubyCodeTypes = [ERBTag, ERBOutputTag].freeze
    attr_accessor :index
    alias_method :old_to_s, :to_s

    def [](obj)
      if obj.is_a?(Fixnum)
        each_with_index do |el, i|
          return el if i == obj
        end
      end
    end

    def ==(other)
      # Necessary to check other.class to prevent comparing a SyntaxNode with a
      # TrueClass instance, for example
      return false unless other.is_a?(self.class) &&
                          length == other.length &&
                          index_eql?(other)
      if nonterminal?
        elements.each_with_index do |el, i|
          return false unless el == other[i]
        end
      end
      true
    end

    def each
      if nonterminal?
        elements.each { |el| yield el }
      end
    end

    def browser_output?
      BrowserOutputTypes.include?(self.class)
    end
    
    def length
      nonterminal? ? elements.length : 0
    end

    def range
      start_index = @index
      end_index = !respond_to?(:close) || @close.nil? ? start_index : @close.index
      (start_index..end_index)
    end

    def same_atomic_section?(other)
      return false if other.nil? || @index.nil? || other.index.nil?
      index_diff = (@index - other.index).abs
      return false if 1 != index_diff
      if PlainHTMLTypes.include?(self.class) && PlainHTMLTypes.include?(other.class)
        return true
      end
      class1_is_output = self.is_a?(ERBOutputTag)
      class2_is_output = other.is_a?(ERBOutputTag)
      if class1_is_output && class2_is_output
        # Two ERBOutputTags
        class1_is_render = ERBOutputTag.sexp_include_call?(self.sexp, :render)
        class2_is_render = ERBOutputTag.sexp_include_call?(other.sexp, :render)
        if !class1_is_render && !class2_is_render
          return true
        else
          # One ERBOutputTag is a render() and the other is not, or they are
          # both render() calls--thus they are two separate atomic sections,
          # using aggregation
          return false
        end
      elsif class1_is_output && ERBOutputTag.sexp_include_call?(self.sexp, :render)
        return false
      elsif class2_is_output && ERBOutputTag.sexp_include_call?(other.sexp, :render)
        return false
      end
      true
    end

    # Thanks to https://github.com/aarongough/koi-reference-parser/blob/
    # development/lib/parser/syntax_node_extensions.rb
    def to_h
      hash = {}
      hash[:offset] = interval.first
      hash[:text_value] = text_value
      hash[:name] = self.class.name.split("::").last
      if elements.nil?
        hash[:elements] = nil
      else
        hash[:elements] = elements.map do |element|
          element.to_h
        end
      end
      hash
    end

    def new_to_s(indent_level=0)
      to_s_with_prefix(indent_level, old_to_s)
    end

    alias_method :to_s, :new_to_s
  end
end
