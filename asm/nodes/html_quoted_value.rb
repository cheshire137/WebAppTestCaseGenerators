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
  class HTMLQuotedValue < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  super(other) && prop_eql?(other, :value)
	end

    def hash
	  prop_hash(:value)
    end

    def inspect
      sprintf("%s: %s", self.class, value)
    end

    def to_s(indent_level=0)
	  to_s_with_prefix(indent_level, value)
    end

    def value
      val.text_value
    end

    def convert
      extract_erb(val.text_value)
    end

    def parenthesize_if_necessary(s)
      return s if s.strip =~ /^\(.*\)$/ || s =~ /^[A-Z0-9_]*$/i
      "(" + s + ")"
    end

    def extract_erb(s, parenthesize = true)
      if s =~ /^(.*?)<%=(.*?)%>(.*?)$/
        pre, code, post = $1, $2, $3
        out = ""
        out = "'#{pre}' + " unless pre.length == 0
        out += parenthesize_if_necessary(code.strip)
        unless post.length == 0
          post = extract_erb(post, false)
          out += " + #{post}"
        end
        out = parenthesize_if_necessary(out) if parenthesize
        out
      else
        "'" + s + "'"
      end
    end
  end
end
