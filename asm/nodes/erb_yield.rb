module ERBGrammar
  class ERBYield < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
    extend SharedAtomicSectionMethods::ClassMethods
	include SharedERBMethods
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedSexpParsing

    def ruby_code
      'yield'
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, 'yield')
    end
  end
end
