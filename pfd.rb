require 'page.rb'
require 'flow.rb'
require 'link.rb'

class PFD
  attr_reader :pages, :links, :flows

  def initialize(pages, links, flows)
    pages.each do |page|
      unless page.is_a? Page
        raise ArgumentError, "Found a non-Page object in pages array"
      end
    end
    links.each do |link|
      unless link.is_a? Link
        raise ArgumentError, "Found a non-Link object in links array"
      end
    end
    flows.each do |flow|
      unless flow.is_a? Flow
        raise ArgumentError, "Found a non-Flow object in flows array"
      end
    end
    @pages = pages
    @links = links
    @flows = flows
  end

  def to_s
    pages_str = @pages.map(&:to_s).join("\n\t")
    links_str = @links.map(&:to_s).join("\n\t")
    flows_str = @flows.map(&:to_s).join("\n\t")
    sprintf("Pages:\n\t%s\nLinks:\n\t%s\nFlows:\n\t%s\n", pages_str, links_str, flows_str)
  end
end
