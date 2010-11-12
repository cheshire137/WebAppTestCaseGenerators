module ERBGrammar
  # Thanks to https://github.com/aarongough/koi-reference-parser/blob/development/lib/parser/syntax_node_extensions.rb
  class Treetop::Runtime::SyntaxNode
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
  end
end
