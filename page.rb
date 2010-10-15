require 'uri'
require 'nokogiri'
require 'open-uri'

class Page
  attr_reader :uri, :links

  def initialize(raw_uri)
    if raw_uri.is_a? String
      @uri = URI.parse(raw_uri)
    elsif raw_uri.is_a? URI
      @uri = raw_uri
    else
      raise ArgumentError, "Only URI and String instances are allowed for given URI"
    end
    @links = Page.get_links(@uri)
  end

  def ==(other)
    other.is_a?(Page) && @uri == other.uri
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri.hash
  end

  def to_s
    sprintf("Page %s (%d links)", @uri.path, @links.length)
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

    def Page.get_links(root_uri)
      target_host = root_uri.host
      doc = Nokogiri::HTML(open(root_uri.to_s))
      doc.css('a').collect do |link|
        get_uri_for_host(link['href'], root_uri)
      end.compact.select do |uri|
        target_host.eql?(uri.host)
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
