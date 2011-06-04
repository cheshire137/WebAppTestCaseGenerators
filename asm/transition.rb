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

require 'uri'

class Transition
  attr_reader :source, :sink, :code

  def initialize(src, snk, c)
    if src.nil?
      raise ArgumentError, "Given source of transition cannot be nil"
    end
	if src.is_a?(String)
	  @source = URI.parse(src)
	else
	  @source = src
	end
    if snk.nil? || !snk.is_a?(RailsURL)
      raise ArgumentError, "Given sink of transition cannot be nil, and must be a RailsURL (got #{snk.class.name})"
    end
    @sink = snk
    if c.nil? || !c.is_a?(String) || c.blank?
      raise ArgumentError, "Given transition code cannot be blank or nil, and must be a String (got #{c.class.name})"
    end
    @code = c
  end

  def inspect
    to_s
  end

  def to_s(prefix='')
    tab = '  '
    sprintf("%s%s<%s> --> <%s>\n%s%sUnderlying code:\n%s%s%s%s",
            tab, prefix, @source, @sink, prefix, tab,
            prefix, tab, tab, (@code || '').strip)
  end
end
