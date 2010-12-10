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
      return false if @sexp.nil?
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
      return false if @sexp.nil?
      [:if, :case, :when].each do |key_word|
        return true if @sexp.include?(key_word)
      end
      false
    end

    # p -> p1* (loops)
    def iteration?
      return false if @sexp.nil?
      [:while, :for, :until].each do |key_word|
        return true if @sexp.include?(key_word)
      end
      return true if ERBTag.sexp_include_call?(@sexp, :each)
      false
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level,
        sprintf("%s\n%s", ruby_code, atomic_section_str(indent_level+1)))
    end

    private
      def self.sexp_include_call?(sexp, method_name)
        # e.g., sexp =
        # s(:iter,
        #   s(:call, s(:ivar, :@names), :each, s(:arglist)),
        #   s(:lasgn, :blah),
        #   s(:call, nil, :puts, s(:arglist, s(:lvar, :blah))))
        return false if sexp.nil? || method_name.nil? || !sexp.is_a?(Enumerable)
        #puts "Looking at:"
        #pp sexp
        if :call == sexp.first && (!sexp[1].nil? && method_name == sexp[1][2] || method_name == sexp[2])
          true
        else
          sexp_include_call?(sexp[1], method_name)
        end
      end
  end
end
