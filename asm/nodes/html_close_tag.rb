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
  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
	include SharedHTMLTagMethods
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods

	def ==(other)
	  super(other) && prop_eql?(other, :name)
	end

    def hash
	  prop_hash(:name)
    end

    def name
      tag_name.text_value.downcase
    end

    def inspect
      sprintf("%s %d: %s", self.class, @index, name)
    end

    def pair_match?(other)
	  opposite_type_same_name?(HTMLOpenTag, other)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, '/' + name)
    end
  end
end
