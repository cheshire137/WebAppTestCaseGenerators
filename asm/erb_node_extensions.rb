module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
    def content
      if x.empty?
        [node.content]
      else
        [node.content] + x.content
      end
    end
  end

  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    def content
      [:erb_output, ruby_code.content_removing_trims]
    end
  end

  class ERBTag < Treetop::Runtime::SyntaxNode
    def content
      [:erb, ruby_code.text_value_removing_trims.strip]
    end
  end

  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_open_tag, tag_name.content, attrs.empty? ? "" : attrs.content]
    end
  end

  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_close_tag, tag_name.content]
    end
  end

  class HTMLSelfClosingTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_self_closing_tag, tag_name.content, attrs.empty? ? "" : attrs.content]
    end
  end

  class HTMLTagAttributes < Treetop::Runtime::SyntaxNode
    def content
      [:html_tag_attributes, [head.content] + (tail.empty? ? [] : tail.elements.first.content.last)]
    end
  end

  class HTMLTagAttribute < Treetop::Runtime::SyntaxNode
    def attr_name
      (n.text_value =~ /[-:]/) ? "'#{n.text_value}'" : ":#{n.text_value}"
    end

    def content
      [:html_tag_attribute, attr_name, v.content]
    end

    def to_s
      "#{attr_name} => #{v.content}"
    end
  end

  class HTMLQuotedValue < Treetop::Runtime::SyntaxNode
    def content
      [:quoted_value, val.text_value]
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

  class RubyCode < Treetop::Runtime::SyntaxNode
    def content_removing_trims
      result.gsub(/\s*\-\s*$/, '')
    end
    
    def text_value_removing_trims
      text_value.gsub(/\s*\-\s*$/, '')
    end
    
    def content
      [:ruby_code, result]
    end

    def result
      code = text_value.strip
      # matches a word, followed by either a word, a string, or a symbol
      code.gsub(/^(\w+) ([\w:"'].*)$/, '\1(\2)')
    end
  end
end
