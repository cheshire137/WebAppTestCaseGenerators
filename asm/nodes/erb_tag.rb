module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
    include SharedERBMethods
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedOpenTagMethods
    attr_accessor :content, :close, :true_content, :false_content

    def atomic_section_str(indent_level=0)
      if @atomic_sections.nil?
        ''
      else
        @atomic_sections.collect do |section|
          section.to_s(indent_level)
        end.join("\n") + "\n"
      end + close_str(indent_level)
    end

    def inspect
      sprintf("%s (%d): %s\n%s", self.class, @index, ruby_code, content_str())
    end

    def to_s(indent_level=0)
      sections = get_sections_and_nodes(:to_s, indent_level+1)
      to_s_with_prefix(indent_level,
        sprintf("%s\n%s\n%s", ruby_code, sections.join("\n"),
                close_str(indent_level+1)))
    end
  end
end
