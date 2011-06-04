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

class Link
  attr_reader :uri1, :uri2, :description
  attr_accessor :target_page

  def initialize(uri1, uri2, target_page, desc)
    unless uri1.respond_to?(:get_uniq_parts) && uri2.respond_to?(:get_uniq_parts)
      raise ArgumentError, "Given URIs must respond to .get_uniq_parts() method"
    end
    unless target_page.respond_to? :uri
      raise ArgumentError, "Given target_page must have .uri property"
    end
    unless uri2.get_uniq_parts() == target_page.uri.get_uniq_parts()
      raise ArgumentError,
        "Given target page does not have same URI as given uri2"
    end
    if desc.nil? || !desc.is_a?(String)
      raise ArgumentError, "Expected String description of link, got #{desc.class.name}"
    end
    @uri1 = uri1
    @uri2 = uri2
    @target_page = target_page
    @description = desc
  end

  def ==(other)
    other.is_a?(Link) && @uri1 == other.uri1 && @uri2 == other.uri2 &&
      @target_page == other.target_page
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri1.hash ^ @uri2.hash ^ @target_page.hash
  end

  def to_s
    sprintf("%s => %s via %s", @uri1.request_uri, @uri2.request_uri, @description)
  end
end
