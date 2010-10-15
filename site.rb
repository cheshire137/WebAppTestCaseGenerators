require 'page.rb'
require 'link.rb'
require 'flow.rb'
require 'pfd.rb'

class Site
  attr_reader :pages, :home

  def initialize(home_page)
    unless home_page.is_a? Page
      raise ArgumentError, "Given home page must be a Page instance"
    end
    @home = home_page
    @pages = Site.get_pages(@home)
  end

  def get_pfd
    pages = [@home, @pages].flatten.uniq
    links = []
    flows = []

    pages.each do |page1|
      page1.links.each do |uri|
        link = Link.new(page1.uri, uri)
        links << link unless links.include? link
        page2 = pages.find { |page| page.uri == uri }
        unless page2.nil?
          flow = Flow.new(page1, link, page2)
          flows << flow unless flows.include? flow
        end
      end
    end

    PFD.new(pages, links, flows)
  end

  def Site.pfd2ptt(pfd)
    first = []
    second = []
    ptt = []
    first << pfd.first
    while true
      puts "First: #{first.inspect}"
      puts "Second: #{second.inspect}"
      puts ""
      return ptt if first.empty?
      cur_page = first[0]
      if second.include? cur_page
        first.delete(cur_page)
        next
      else
        second << cur_page
      end
      cur_page.links.each do |uri|
        ptt << uri
        first << Page.new(uri)
      end
      first.delete(cur_page)
    end
  end

  def to_s
    nodes = [@home, @pages].flatten
    nodes.map(&:to_s).join("\n")
  end

  private
    def Site.get_pages(root_page)
      root_page.links.collect do |uri|
        Page.new(uri)
      end.uniq
    end
end

