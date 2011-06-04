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

require File.join(File.expand_path(File.dirname(__FILE__)), 'uri_extensions.rb')

class LinkText
  attr_reader :uri, :uri_parts, :description

  def initialize(u, desc)
    if u.nil? || !u.is_a?(URI)
      raise ArgumentError, "Expected URI, got #{u.class.name}"
    end
    @uri = u
    if desc.nil? || !desc.is_a?(String)
      raise ArgumentError, "Expected String of link description, got #{desc.class.name}"
    end
    @description = desc
    @uri_parts = @uri.get_uniq_parts()
  end

  def ==(other)
    other.is_a?(LinkText) && @uri_parts == other.uri_parts && @description == other.description
  end

  def <=>(other)
    @description <=> other.description
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri.hash ^ @description.hash
  end
end
