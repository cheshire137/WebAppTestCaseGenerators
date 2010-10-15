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
      @uri = URI.parse(raw_uri)
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
        doc = Nokogiri::HTML(open(uri.to_s))
        doc.css('a').map { |link| link['href'] }
      end
  end
end
