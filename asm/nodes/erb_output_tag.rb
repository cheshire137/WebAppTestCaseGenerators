module ERBGrammar
  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
    extend SharedAtomicSectionMethods::ClassMethods
	include SharedERBMethods
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedSexpParsing
    include SharedTransitionMethods
    LINK_METHODS = [:link_to, :link_to_remote, :link_to_unless_current,
      :link_to_unless, :link_to_if, :link_to_function].freeze
    attr_accessor :atomic_section_count

    def content
      nil
    end

    def get_local_transitions(source)
      set_sexp() if @sexp.nil?
      get_link_transitions(source)
    end

    def inspect
      sprintf("%s (%d): %s", self.class, @index, ruby_code())
    end

    def ruby_code
      code.content_removing_trims()
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, '<%= ' + ruby_code())
    end

    private
      def get_link_transitions(source)
        transitions = []
        LINK_METHODS.each do |link_method|
          link_args = ERBOutputTag.get_sexp_for_call_args(sexp, link_method)
          unless link_args.nil?
            #puts "Found call to #{link_method}() with args:"
            #pp link_args
            #puts "Sexp:"
            #pp @sexp
            args_hash = link_args.find { |sexp| :hash == sexp.first }
            unless args_hash.nil?
              controller = (ERBTag.get_sexp_hash_value(args_hash, :controller) || '').to_s
              action = (ERBTag.get_sexp_hash_value(args_hash, :action) || '').to_s
              sink = sprintf("%s/%s", controller, action)
              transitions << LinkTransition.new(source, sink, ruby_code())
            end
          end
        end
        transitions
      end
  end
end
