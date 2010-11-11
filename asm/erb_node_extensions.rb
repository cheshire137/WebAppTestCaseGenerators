module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
    def content
      elements.collect do |node|
        if node.respond_to? :content
          node.content
        else
          node.inspect
        end
      end
    end
  end

  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    def content
      [:erb_output, elements[1].content]
    end
  end

  class ERBTag < Treetop::Runtime::SyntaxNode
    def content
      [:erb, elements[1].content]
    end
  end

  class HTMLTagPair < Treetop::Runtime::SyntaxNode
    def content
      [:html_tag_pair, elements.inspect]
    end
  end

  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_open_tag, elements[1].content, elements[2].content]
    end
  end

  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_close_tag, elements[1].content]
    end
  end

  class HTMLSelfClosingTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_self_closing_tag, tag_name.text_value, attrs.empty? ? "" : attrs.content]
    end
  end
end
