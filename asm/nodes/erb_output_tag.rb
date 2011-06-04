# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
            sink = get_target_page_from_sexp(link_args)
            unless sink.nil?
              transitions << LinkTransition.new(source, sink, ruby_code())
            end
          end
        end
        transitions
      end
  end
end
