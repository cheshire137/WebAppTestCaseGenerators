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

module SharedMethods
  def eql?(other)
	return false unless other.is_a?(self.class)
	self == other
  end

  def index_eql?(other)
	return false if other.nil?
	@index.nil? && other.index.nil? || @index == other.index
  end

  def prop_eql?(other, *property_names)
	property_names.each do |prop_name|
	  return false unless self.send(prop_name) == other.send(prop_name)
	end
	true
  end

  def prop_hash(*property_names)
	hash_code = 0
	property_names << :index unless property_names.include? :index
	property_names.each do |prop_name|
	  prop_value = self.send(prop_name)
	  hash_code = hash_code ^ prop_value.hash unless prop_value.nil?
	end
	hash_code
  end

  def to_s_with_prefix(indent_level=0, suffix='', prefix='  ')
	close_str = if !respond_to?(:close) || @close.nil?
				  ''
                elsif @close.respond_to?(:range)
                  sprintf("-%d", @close.range.to_a.last)
                else
				  sprintf("-%d", @close.index)
				end
	sprintf("%s%d%s: %s", prefix * indent_level, @index, close_str, suffix)
  end
end
