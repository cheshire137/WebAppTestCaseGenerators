require 'matrix'
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
      page1.link_uris.each do |uri|
        page2 = pages.find { |page| page.uri == uri }
        next if page2.nil?
        new_link = Link.new(page1.uri, uri, page2.dup)
        page1.links << new_link
        links << new_link unless links.include? new_link
        flow = Flow.new(page1, new_link, page2.dup)
        flows << flow unless flows.include? flow
      end
    end
    PFD.new(pages, links, flows)
  end

  def Site.pfd2ptt(pfd)
    copies = []
    first = []
    second = []
    ptt_flows = []
    puts "---Pages before: " + pfd.pages.map(&:to_s).join("\n")

    # Step 1
    first << pfd.pages[0]

    while !first.empty?
      # Step 3
      next_page = first[0]

      if !second.map(&:uri).include?(next_page.uri)
        second << next_page

        # Step 4:  if page is linking to other pages:
        if !next_page.links.empty?
          next_page.links.each do |link|
            linked_page = link.target_page
            if first.include?(linked_page) || second.include?(linked_page)
              copy = linked_page.dup
              link.target_page = copy
              first << copy
            else
              first << linked_page
            end
          end
        end
      end

      # Step 5
      first.delete(next_page)
    end
    printf("First: %s\n\nSecond: %s\n",
      first.map(&:to_s).join("\n"),
      second.map(&:to_s).join("\n"))
    puts "---Pages after: " + pfd.pages.map(&:to_s).join("\n")
  end

  def to_s
    nodes = [@home, @pages].flatten
    nodes.map(&:to_s).join("\n")
  end

  private
    def Site.get_pages(root_page)
      root_page.link_uris.collect do |uri|
        Page.new(uri)
      end.uniq
    end
end

