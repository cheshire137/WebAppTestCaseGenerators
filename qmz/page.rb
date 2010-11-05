require 'rubygems'
require 'nokogiri'
require 'uri'
require 'open-uri'

class Page
  attr_reader :uri, :link_uris, :links
  attr_accessor :is_copy

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
    printf("Getting links for page %s...\n", @uri.request_uri)
    @link_uris = Page.get_link_uris(@uri, html)
    printf("\tGot %d links for page\n", @link_uris.length)
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

  def hash
    @uri.hash
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

  private
    def Page.get_uri_for_host(str, host_uri)
      if str.nil?
        raise ArgumentError, "Cannot work with nil URI string"
      end
      unless str.is_a? String
        raise ArgumentError,
          "Given URI string must be a String, was given a(n) " + str.class.name
      end
      unless host_uri.is_a? URI
        raise ArgumentError, "Given host must be a URI, was given a(n) " +
          host_uri.class.name
      end
      uri = parse_uri_forgivingly(str)
      if !uri.nil? && uri.is_a?(URI::Generic) && uri.host.nil?
        uri = parse_uri_forgivingly(
          sprintf("%s://%s%s", host_uri.scheme, host_uri.host, uri.to_s)
        )
      end
      uri
    end

    def Page.get_link_uris(root_uri, html)
      target_host = root_uri.host
      doc = Nokogiri::HTML(html)
      hyperlink_uris = extract_uris_on_host(
        doc.css('a').select do |link|
          !link['href'].nil?
        end.collect do |link|
          get_uri_for_host(link['href'], root_uri)
        end,
        target_host
      )
      button_uris = extract_uris_on_host(
        doc.css('form').select do |form|
          if form['action'].nil?
            false
          else
            input_types = form.css('input').collect do |input|
              input['type']
            end.map(&:downcase)
            input_types.include?('submit') || input_types.include?('image')
          end
        end.collect do |form|
          get_uri_for_host(form['action'], root_uri)
        end,
        target_host
      )
      (hyperlink_uris + button_uris).uniq
    end

    def Page.extract_uris_on_host(uris, target_host)
      uris.compact.select do |uri|
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
