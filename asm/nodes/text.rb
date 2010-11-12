module ERBGrammar
  class Text < Treetop::Runtime::SyntaxNode
    attr_accessor :index
    def to_s
      stripped = text_value.strip
      if stripped.empty?
        ""
      else
        #stripped.html_unescape.gsub(/\'/, "\\\\'")
        stripped.gsub(/\'/, "\\\\'")
      end
    end
  end
end
