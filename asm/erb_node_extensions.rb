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

  class HTMLEmptyTag < Treetop::Runtime::SyntaxNode
    def content
      [:html_empty_tag, elements[1].content, elements[2].content]
    end
  end
end
