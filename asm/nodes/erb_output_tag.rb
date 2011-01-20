module ERBGrammar
  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
	include SharedERBMethods
    extend SharedERBMethods::ClassMethods
    attr_reader :parsed_sexp
    attr_accessor :atomic_section_count

    def inspect
      sprintf("%s (%d): %s", self.class, @index, ruby_code)
    end

    def sexp
      return @parsed_sexp unless @parsed_sexp.nil?
      parser = RubyParser.new
      begin
        @parsed_sexp = parser.parse(ruby_code)
      rescue Racc::ParseError
        @parsed_sexp = :invalid_ruby
      end
      @parsed_sexp
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, '<%= ' + ruby_code)
    end
  end
end
