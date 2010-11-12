module ERBGrammar
  class HTMLQuotedValue < Treetop::Runtime::SyntaxNode
    attr_accessor :index
    def eql?(other)
      return false unless other.is_a?(self.class)
      value == other.value
    end
    def hash
      value.hash
    end
    def inspect
      sprintf("%s: %s", self.class, value)
    end
    def to_s(indent_level=0)
      Tab * indent_level + value
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
        #pre, code, post = $1.html_unescape.escape_single_quotes, $2, $3.html_unescape.escape_single_quotes
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
        #"'" + s.html_unescape.escape_single_quotes + "'"
        "'" + s + "'"
      end
    end
  end
end
