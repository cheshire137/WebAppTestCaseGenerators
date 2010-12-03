module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    include SharedERBMethods
    include SharedOpenTagMethods
    attr_accessor :content, :close, :sexp
    attr_reader :atomic_sections

    def add_atomic_section(section)
      return if section.nil?
      section_index = section.index
      if @atomic_sections.nil? || @atomic_sections.empty?
        @atomic_sections = [section]
      else
        prev_section_index = @atomic_sections.index { |s| s.index > section_index }
        if prev_section_index.nil?
          @atomic_sections << section
        else
          @atomic_sections.insert(prev_section_index, section)
        end
      end
    end

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

    def nest_atomic_sections
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level,
        sprintf("%s\n%s", ruby_code, atomic_section_str(indent_level+1)))
    end
  end
end
