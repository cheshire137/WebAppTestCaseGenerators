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

  def ==(other)
    return false unless other.is_a?(PFD)
    if @pages.length != other.pages.length ||
       @links.length != other.links.length ||
       @flows.length != other.flows.length
      return false
    end
    @pages.each do |page|
      return false unless other.pages.include?(page)
    end
    other.pages.each do |page|
      return false unless @pages.include?(page)
    end
    @links.each do |link|
      return false unless other.links.include?(link)
    end
    other.links.each do |link|
      return false unless @links.include?(link)
    end
    @flows.each do |flow|
      return false unless other.flows.include?(flow)
    end
    other.flows.each do |flow|
      return false unless @flows.include?(flow)
    end
    return true
  end

  def eql?(other)
    self == other
  end

  def hash
    hash_code = 1
    @pages.each do |page|
      hash_code = hash_code ^ page.hash
    end
    @links.each do |link|
      hash_code = hash_code ^ link.hash
    end
    @flows.each do |flow|
      hash_code = hash_code ^ flow.hash
    end
    hash_code
  end

  def to_s
    pages_str = @pages.map(&:to_s).join("\n\t")
    links_str = @links.map(&:to_s).join("\n\t")
    flows_str = @flows.map(&:to_s).join("\n\t")
    sprintf("Pages (%d):\n\t%s\nLinks (%d):\n\t%s\nFlows (%d):\n\t%s\n",
      @pages.length,
      pages_str,
      @links.length,
      links_str,
      @flows.length,
      flows_str)
  end
end
