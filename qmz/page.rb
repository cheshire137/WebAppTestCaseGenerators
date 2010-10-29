require 'uri'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Page
  attr_reader :uri, :link_uris, :links

  def initialize(raw_uri)
    if raw_uri.is_a? String
      @uri = URI.parse(raw_uri)
    elsif raw_uri.is_a? URI
      @uri = raw_uri
    else
      raise ArgumentError, "Only URI and String instances are allowed for given URI"
    end
    @link_uris = Page.get_link_uris(@uri)
    @links = []
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

  def to_s
    str = sprintf("Page %s (%d links", @uri.path, @link_uris.length)
    unless @links.empty?
      str << ': '
      str << @links.map(&:to_s).join(', ')
    end
    str << ')'
    str
  end

  def to_tree_s
    tree = sprintf("%s\n", @uri.path)
    @links.each do |uri|
      tree << sprintf("%s\n", @uri.path)
    end
  end

  private
    def Page.get_uri_for_host(str, host_uri)
      unless str.is_a? String
        raise ArgumentError, "Given URI string must be a String"
      end
      unless host_uri.is_a? URI
        raise ArgumentError, "Given host must be a URI"
      end
      uri = parse_uri_forgivingly(str)
      if !uri.nil? && uri.is_a?(URI::Generic) && uri.host.nil?
        uri = parse_uri_forgivingly(
          sprintf("%s://%s%s", host_uri.scheme, host_uri.host, uri.to_s)
        )
      end
      uri
    end

    def Page.get_link_uris(root_uri)
      target_host = root_uri.host
      doc = Nokogiri::HTML(open(root_uri.to_s))
      doc.css('a').collect do |link|
        get_uri_for_host(link['href'], root_uri)
      end.compact.select do |uri|
        target_host == uri.host
      end.uniq
    end

    def Page.parse_uri_forgivingly(str)
      begin
        URI.parse(str)
      rescue URI::InvalidURIError
        nil
      end
    end
end
