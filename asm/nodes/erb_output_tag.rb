module ERBGrammar
  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
	include SharedERBMethods
    extend SharedERBMethods::ClassMethods
    include SharedSexpParsing
    attr_accessor :atomic_section_count

    def inspect
      sprintf("%s (%d): %s", self.class, @index, ruby_code)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, '<%= ' + ruby_code)
    end
  end
end
