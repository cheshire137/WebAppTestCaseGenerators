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

require 'rubygems'
require 'open-uri'
require File.join(File.join(File.expand_path(File.dirname(__FILE__)), '..'), 'html_parsing.rb')
require File.join(File.join(File.expand_path(File.dirname(__FILE__)), '..'), 'uri_extensions.rb')

class Page
  include SharedHtmlParsing
  extend SharedHtmlParsing::ClassMethods
  attr_reader :uri, :links, :uri_parts
  attr_accessor :is_copy, :link_texts

  def initialize(raw_uri, html=nil)
    if raw_uri.is_a? String
      @uri = Page.parse_uri_forgivingly(raw_uri)
      if @uri.nil?
        raise ArgumentError, "Could not parse given String URI #{raw_uri}"
      end
    elsif raw_uri.is_a? URI
      @uri = raw_uri
    else
      raise ArgumentError, "Only URI and String instances are allowed for given URI (got #{raw_uri.class.name})"
    end
    if html.nil? || !html.is_a?(Nokogiri::HTML::Document)
      html = Page.open_uri(raw_uri)
      if html.nil?
        raise ArgumentError, "Could not open URI for page #{@uri}"
      end
    end
    @uri_parts = @uri.get_uniq_parts()
    @link_texts = (Page.get_link_uris_with_text(@uri, html) +
      Page.get_form_uris_with_text(@uri, html)).uniq
    @links = []
    @is_copy = false
  end

  def ==(other)
    other.is_a?(Page) && @uri == other.uri
  end

  def <=>(other)
    @uri <=> other.uri
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri.hash
  end

  def Page.open_uri(uri)
    return nil if uri.nil?
    begin
      stringio = open(uri.to_s)
    rescue => err
      printf("Got error '%s' trying to open URI %s, skipping...\n",
        err.to_s, uri.to_s)
      stringio = nil
    end
    stringio.nil? || stringio.content_type != 'text/html' ? nil : Nokogiri::HTML(stringio)
  end

  def to_s
    str = sprintf("Page %s (%d links", @uri.request_uri, @link_texts.length)
    unless @links.empty?
      str << ': '
      str << @links.map(&:to_s).join(', ')
    end
    str << ')'
    str
  end
end
