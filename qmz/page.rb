require 'rubygems'
require 'uri_extensions.rb'
require 'open-uri'
require 'pp'
require File.join('..', 'html_parsing.rb')

class Page
  include SharedHtmlParsing
  extend SharedHtmlParsing::ClassMethods
  attr_reader :uri, :links, :uri_parts
  attr_accessor :is_copy, :link_uris, :link_uri_parts

  def initialize(raw_uri, html=nil)
    if raw_uri.is_a? String
      @uri = URI.parse(raw_uri)
    elsif raw_uri.is_a? URI
      @uri = raw_uri
    else
      raise ArgumentError, "Only URI and String instances are allowed for given URI"
    end
    if html.nil?
      html = Page.open_uri(raw_uri)
      if html.nil?
        raise ArgumentError, "Could not open URI for page"
      end
    end
    @uri_parts = @uri.get_uniq_parts()
    @link_uris = (Page.get_link_uris(@uri, html) + Page.get_form_uris(@uri, html)).uniq
    puts "Link URIs:"
    pp @link_uris
    @link_uri_parts = @link_uris.map { |uri| uri.get_uniq_parts() }
    @links = []
    @is_copy = false
    printf("New %s\n", to_s)
  end

  def ==(other)
    other.is_a?(Page) && @uri == other.uri
  end

  def <=>(other)
    @uri <=> other.uri
  end

  def delete_link_at(i)
    @link_uris.delete_at(i)
    @link_uri_parts.delete_at(i)
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri.hash
  end

  def Page.open_uri(uri)
    begin
      open(uri.to_s)
    rescue OpenURI::HTTPError => err
      uri_desc = uri.respond_to?(:request_uri) ? uri.request_uri : uri.to_s
      printf("Got error '%s' trying to open URI %s, skipping...\n",
        err.to_s, uri_desc)
      nil
    end
  end

  def to_s
    str = sprintf("Page %s (%d links", @uri.request_uri, @link_uris.length)
    unless @links.empty?
      str << ': '
      str << @links.map(&:to_s).join(', ')
    end
    str << ')'
    str
  end
end
