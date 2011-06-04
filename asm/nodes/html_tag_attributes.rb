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
  class HTMLTagAttributes < Treetop::Runtime::SyntaxNode
    include SharedSexpParsing
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedHTMLTagMethods

	def ==(other)
	  return false unless super(other) && index_eql?(other)
	  this_arr = to_a
      other_arr = other.to_a
      return false if this_arr.length != other_arr.length
      this_arr.each_with_index do |el, i|
        return false unless el == other_arr[i]
      end
	  true
	end

    def hash
      h = prop_hash()
      to_a.each do |el|
        h = h ^ el.hash
      end
      h
    end

    def to_a
      arr = [head]
      unless tail.empty?
        arr += tail.elements.first.to_a
      end
      arr
    end

    def to_h
      hash = {}
      hash[head.name] = head.value
      unless tail.empty?
        hash.merge!(tail.elements.first.to_h)
      end
      hash
    end

    def to_s(indent_level=0)
      to_a.map(&:to_s).join(', ')
    end
  end
end
