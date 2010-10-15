require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'

module QmzScraperShared
  def print_help
    printf("Usage: %s uri_to_site_home_page\n", $0)
  end

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

    def to_s
      separator = '=>'
      tab_size = @uri.to_s.length
      joined_links = @links.join(
        sprintf("\n%s %s ", ' ' * tab_size, separator)
      )
      sprintf("%s %s %s", @uri, separator, joined_links)
    end

    private
      def Page.get_links(uri)
        printf("Getting all links for %s...\n", uri)
        target_host = uri.host
        doc = Nokogiri::HTML(open(uri.to_s))
        doc.css('a').collect do |link|
          begin
            URI.parse(link['href'])
          rescue URI::InvalidURIError
            nil
          end
        end.compact.select do |uri|
          (uri.is_a?(URI::Generic) && uri.host.nil?) ||
            target_host.equal?(uri.host)
        end.uniq
      end
  end

  class Site
    attr_reader :pages, :home

    def initialize(home_page)
      unless home_page.is_a? Page
        raise ArgumentError, "Given home page must be a Page instance"
      end
      @home = home_page
      @pages = Site.get_pages(@home)
    end

    def to_s
      separator = '=>'
      home_desc = @home.to_s
      home_desc_lines = home_desc.split
      tab_size = home_desc_lines.max do |a, b|
        a.length <=> b.length
      end.length
      joined_pages = @pages.map(&:to_s).join(
        sprintf("\n%s %s ", ' ' * tab_size, separator)
      )
      sprintf("%s %s %s", home_desc, separator, joined_pages)
    end

    private
      def Site.get_pages(root_page)
        printf("Getting all pages for\n%s...\n", root_page)
        root_page.links.collect do |uri|
          Page.new(
            if uri.is_a?(URI::Generic) && uri.host.nil?
              root_uri = root_page.uri
              URI.parse(
                sprintf("%s://%s%s", root_uri.scheme, root_uri.host, uri.to_s)
              )
            else
              uri
            end
          )
        end
      end
  end
end
