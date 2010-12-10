module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
    include SharedERBMethods
    include SharedOpenTagMethods
    attr_accessor :content, :close, :sexp

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

    # p -> p1{p2} (file inclusion, function calls in p1)
    def aggregation?
      # TODO: will this ever be true?  is yield/render ever in an ERBTag?
      false
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

    # p -> p1 | p2 (conditionals)
    def selection?
      return true if ERBTag.code_has_conditional?(@sexp)
      return true if !@close.nil? && ERBTag.code_has_conditional?(@close.sexp)
      false
    end

    # p -> p1* (loops)
    def iteration?
      return true if ERBTag.code_has_loop?(@sexp)
      return true if !@close.nil? && ERBTag.code_has_loop?(@close.sexp)
      false
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level,
        sprintf("%s\n%s", ruby_code, atomic_section_str(indent_level+1)))
    end

    private
      def self.code_has_conditional?(sexp)
        return false if sexp.nil?
        [:if, :case, :when].each do |key_word|
          return true if sexp.include?(key_word)
        end
      end

      def self.code_has_loop?(sexp)
        return false if sexp.nil?
        [:iter, :while, :for, :until].each do |key_word|
          return true if sexp.include?(key_word)
        end
        false
      end
  end
end
