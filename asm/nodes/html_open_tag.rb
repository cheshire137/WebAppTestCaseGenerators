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

require File.join(
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..')),
  'html_parsing.rb'
)
require 'rubygems'
require 'nokogiri'

module ERBGrammar
  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    include SharedOpenTagMethods
    include SharedHTMLTagMethods
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedTransitionMethods
    include SharedHtmlParsing
    extend SharedHtmlParsing::ClassMethods
    attr_accessor :content, :close

    def ==(other)
      super(other) && prop_eql?(other, :name, :attributes_str)
    end

    def attributes
      attrs.empty? ? [] : attrs.to_a
    end

    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end

    def get_local_transitions(source)
      trans = []
      tag_name = name()
      if source.is_a?(RailsURL)
        source_uri = source.to_uri()
      else
        source_uri = source
      end
      doc = Nokogiri::HTML(text_value)
      HTMLOpenTag.get_link_uris(source_uri, doc).each do |sink|
        trans << LinkTransition.new(source, RailsURL.from_uri(sink), text_value)
      end
      HTMLOpenTag.get_form_uris(source_uri, doc).each do |sink|
        trans << FormTransition.new(source, RailsURL.from_uri(sink), text_value)
      end
      trans
    end

    def hash
      prop_hash(:name, :attributes_str)
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s (%d): %s %s", self.class, @index, name, attributes_str)
    end

    def pair_match?(other)
      opposite_type_same_name?(HTMLCloseTag, other)
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level, sprintf("%s %s\n%s",
        name, attributes_str, content_str(indent_level+1)))
    end
  end
end
