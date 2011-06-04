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
  class Treetop::Runtime::SyntaxNode
    include Enumerable
    include SharedMethods
    PlainHTMLTypes = [HTMLDirective, HTMLOpenTag, HTMLCloseTag, Whitespace, Text, HTMLDoctype, HTMLQuotedValue, HTMLSelfClosingTag, HTMLTagAttribute].freeze
    ERBOutputTypes = [ERBOutputTag, ERBYield].freeze
    BrowserOutputTypes = (PlainHTMLTypes + ERBOutputTypes).freeze
    RubyCodeTypes = ([ERBTag] + ERBOutputTypes).freeze
    attr_accessor :index
    alias_method :old_to_s, :to_s

    def [](obj)
      if obj.is_a?(Fixnum)
        each_with_index do |el, i|
          return el if i == obj
        end
      end
    end

    def ==(other)
      # Necessary to check other.class to prevent comparing a SyntaxNode with a
      # TrueClass instance, for example
      return false unless other.is_a?(self.class) &&
                          length == other.length &&
                          index_eql?(other)
      if nonterminal?
        elements.each_with_index do |el, i|
          return false unless el == other[i]
        end
      end
      true
    end

    def each
      if nonterminal?
        elements.each { |el| yield el }
      end
    end

    def browser_output?
      BrowserOutputTypes.include?(self.class)
    end
    
    def length
      nonterminal? ? elements.length : 0
    end

    def range
      start_index = @index
      end_index = (!respond_to?(:close) || @close.nil?) ? start_index : @close.index
      (start_index..end_index)
    end

    def same_atomic_section?(other)
      return false if other.nil? || @index.nil? || other.index.nil?
      index_diff = (@index - other.index).abs
      return false if 1 != index_diff

      # If both nodes are just HTML, they can be part of the same atomic
      # section
      is_plain_html = PlainHTMLTypes.include?(self.class)
      other_is_plain_html = PlainHTMLTypes.include?(other.class)
      return true if is_plain_html && other_is_plain_html

      # If one node is an ERBTag and the other is not, they should not
      # be in the same atomic section--ERBTags split apart atomic sections
      is_erb = self.is_a?(ERBTag)
      other_is_erb = other.is_a?(ERBTag)
      return false if !is_erb && other_is_erb || is_erb && !other_is_erb

      class1_is_output = self.is_a?(ERBOutputTag)
      class2_is_output = other.is_a?(ERBOutputTag)
      if class1_is_output && class2_is_output
        # Two ERBOutputTags
        class1_is_render = ERBOutputTag.sexp_include_call?(self.sexp, :render)
        class2_is_render = ERBOutputTag.sexp_include_call?(other.sexp, :render)
        if !class1_is_render && !class2_is_render
          return true
        else
          # One ERBOutputTag is a render() and the other is not, or they are
          # both render() calls--thus they are two separate atomic sections,
          # using aggregation
          return false
        end
      elsif class1_is_output && ERBOutputTag.sexp_include_call?(self.sexp, :render)
        return false
      elsif class2_is_output && ERBOutputTag.sexp_include_call?(other.sexp, :render)
        return false
      end
      true
    end

    # Thanks to https://github.com/aarongough/koi-reference-parser/blob/
    # development/lib/parser/syntax_node_extensions.rb
    def to_h
      hash = {}
      hash[:offset] = interval.first
      hash[:text_value] = text_value
      hash[:name] = self.class.name.split("::").last
      if elements.nil?
        hash[:elements] = nil
      else
        hash[:elements] = elements.map do |element|
          element.to_h
        end
      end
      hash
    end

    def new_to_s(indent_level=0)
      to_s_with_prefix(indent_level, old_to_s)
    end

    alias_method :to_s, :new_to_s
  end
end
