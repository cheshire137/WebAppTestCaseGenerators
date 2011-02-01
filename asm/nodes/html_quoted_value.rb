module ERBGrammar
  class HTMLQuotedValue < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  super(other) && prop_eql?(other, :value)
	end

    def hash
	  prop_hash(:value)
    end

    def inspect
      sprintf("%s: %s", self.class, value)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, value)
    end

    def value
      val.text_value
    end

    def convert
      extract_erb(val.text_value)
    end

    def parenthesize_if_necessary(s)
      return s if s.strip =~ /^\(.*\)$/ || s =~ /^[A-Z0-9_]*$/i
      "(" + s + ")"
    end

    def extract_erb(s, parenthesize = true)
      if s =~ /^(.*?)<%=(.*?)%>(.*?)$/
        pre, code, post = $1, $2, $3
        out = ""
        out = "'#{pre}' + " unless pre.length == 0
        out += parenthesize_if_necessary(code.strip)
        unless post.length == 0
          post = extract_erb(post, false)
          out += " + #{post}"
        end
        out = parenthesize_if_necessary(out) if parenthesize
        out
      else
        "'" + s + "'"
      end
    end
  end
end
