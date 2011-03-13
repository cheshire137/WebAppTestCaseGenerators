module ERBGrammar
  class ERBTag < Treetop::Runtime::SyntaxNode
    include SharedAtomicSectionMethods
    extend SharedAtomicSectionMethods::ClassMethods
    include SharedChildrenMethods
    include SharedERBMethods
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedTransitionMethods
    include SharedOpenTagMethods
    FORM_METHODS = [:form_tag, :form_remote_tag].freeze
    REDIRECT_METHODS = [:redirect_to, :redirect_to_full_url].freeze
    attr_accessor :content, :parent, :close, :true_content, :false_content, :overridden_ruby_code

    def atomic_section_str(indent_level=0)
      if @atomic_sections.nil?
        ''
      else
        @atomic_sections.collect do |section|
          section.to_s(indent_level)
        end.join("\n") + "\n"
      end + close_str(indent_level)
    end

    def get_local_transitions(source)
      set_sexp() if @sexp.nil?
      trans = get_form_transitions(source)
      trans += get_redirect_transitions(source)
      trans
    end

    def inspect
      sprintf("%s (%d): %s\n%s", self.class, @index, ruby_code, content_str())
    end

    def ruby_code
      if @overridden_ruby_code.nil?
        code.content_removing_trims()
      else
        @overridden_ruby_code
      end
    end

    def to_s(indent_level=0)
      sections = get_sections_and_nodes(:to_s, indent_level+2)
      prefix = '  '
      content_prefix = sections.empty? ? '' : sprintf("%sContent and sections:\n", prefix * (indent_level+1))
      close_string = close_str(indent_level+2)
      close_prefix = close_string.blank? ? '' : sprintf("%sClose:\n", prefix * (indent_level+1))
      to_s_with_prefix(indent_level,
        sprintf("%s\n%s%s\n%s%s", ruby_code, content_prefix,
                sections.join("\n"), close_prefix, close_string))
    end

    private
      def get_form_transitions(source)
        transitions = []
        FORM_METHODS.each do |form_method|
          form_args = ERBTag.get_sexp_for_call_args(@sexp, form_method)
          unless form_args.nil?
            sink = get_target_page_from_sexp(form_args, source)
            unless sink.nil?
              transitions << FormTransition.new(source, sink, ruby_code())
            end
          end
        end
        transitions
      end

      def get_redirect_transitions(source)
        transitions = []
        REDIRECT_METHODS.each do |redirect_method|
          redirect_args = ERBTag.get_sexp_for_call_args(@sexp, redirect_method)
          unless redirect_args.nil?
            sink = get_target_page_from_sexp(redirect_args, source)
            unless sink.nil?
              transitions << RedirectTransition.new(source, sink, ruby_code())
            end
          end
        end
        transitions
      end
  end
end
