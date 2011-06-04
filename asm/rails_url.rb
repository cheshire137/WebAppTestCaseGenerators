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
require File.join(File.expand_path(File.join(File.dirname(__FILE__), '..')), 'html_parsing.rb')

class RailsURL
	extend SharedHtmlParsing::ClassMethods
  attr_reader :action, :controller, :raw_url, :site_root

  def initialize(ctrlr, act, raw, root='')
    if (ctrlr.nil? || ctrlr.to_s.blank?) && (act.nil? || act.to_s.blank?) && (raw.nil? || raw.to_s.blank?)
      raise ArgumentError, "Must provide at least one non-null part of URL"
    end
    @controller = (ctrlr || '').to_s.strip.downcase
    @action = (act || '').to_s.strip.downcase
    @raw_url = (raw || '').to_s.strip.downcase
    @site_root = root.to_s.strip.downcase
  end

  def RailsURL.from_path(path, site_root='')
    return nil if path.nil?
    path_parts = path.split(File::ALT_SEPARATOR)
    path = File.join(path_parts)
    controller_prefix = File.join('app', 'views')
    prefix_start = path.index(controller_prefix)
    return nil if prefix_start.nil?
    controller_index = prefix_start + controller_prefix.length
    with_ext = path[controller_index...path.length]
    ext_start = with_ext.index('.') || with_ext.length
    without_ext = with_ext[0...ext_start]
    controller = File.dirname(without_ext).gsub(/^\//, '')
    action = File.basename(without_ext)
    RailsURL.new(controller, action, nil, site_root)
  end
  
  def RailsURL.from_uri(uri)
    if uri.nil? || !uri.is_a?(URI)
      raise ArgumentError, "Expected non-nil URI, got #{uri.class.name}"
    end
    RailsURL.new(nil, nil, uri.to_s)
  end
  
  def relative?
    uri = to_uri()
    uri.nil? ? false : uri.relative?
  end

  def url
    if @raw_url.blank?
      sprintf("%s/%s/%s", @site_root, @controller, @action)
    else
      # TODO: prefix with @site_root if necessary (relative URL)
      @raw_url
    end
  end

  def to_s
    #sprintf("%sRailsURL\n\t%sController: %s\n\t%sAction: %s\n\t%sRaw URL: %s",
    #        prefix, prefix, @controller, prefix, @action, prefix, @raw_url)
    url()
  end
  
  def to_uri
    RailsURL.parse_uri_forgivingly(url())
  end
end
