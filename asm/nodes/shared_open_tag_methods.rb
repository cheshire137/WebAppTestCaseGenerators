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

module SharedOpenTagMethods
  def close_str(indent_level=0)
	@close.nil? ? '' : @close.to_s(indent_level)
  end

  def content_str(indent_level=0)
	if @content.nil?
	  ''
	else
	  @content.collect do |el|
		el.to_s(indent_level)
	  end.join("\n") + "\n"
	end + close_str(indent_level)
  end
end
