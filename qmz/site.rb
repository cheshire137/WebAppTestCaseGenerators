require 'matrix'
require 'page.rb'
require 'link.rb'
require 'pfd.rb'

class Site
  attr_reader :pages, :home

  def initialize(home_page)
    unless home_page.is_a? Page
      raise ArgumentError, "Given home page must be a Page instance"
    end
    @home = home_page
    @pages = Site.get_pages(@home, [])
  end

  def get_pfd
    pages = [@home, @pages].flatten.uniq
    links = []
    pages.each do |page1|
      page1.link_uris.each do |uri|
        page2 = pages.find { |page| page.uri == uri }
        if page2.nil?
          printf("ERR: cannot find page with URI %s in site\n", uri.path)
          next
        end
        new_link = Link.new(page1.uri, uri, page2)
        page1.links << new_link
        links << new_link unless links.include? new_link
      end
    end
    PFD.new(pages, links)
  end

  def Site.pfd2ptt(pfd)
    ptt = pfd.dup
    first = []
    second = []

    # Step 1
    first << ptt.pages[0]

    while !first.empty?
      # Step 3
      next_page = first[0]

      # If pid is within SECOND, then go to (5). Otherwise, add it into the end
      # of SECOND
      unless second.include? next_page
        second << next_page

        # Step 4:  if pid is linking to other pages:
        next_page.links.each do |link|
          linked_page = link.target_page

          # If some of the other page identifiers are within FIRST or SECOND:
          if first.include?(linked_page) || second.include?(linked_page)
            # Then generate their copies
            copy = linked_page.dup
            copy.is_copy = true

            # Retain the links between pid and the other pages (or their
            # copies) of the PFD
            link.target_page = copy

            # Add the other page identifiers (or their copies) into the end
            # of FIRST
            first << copy
          else
            # Add the other page identifiers (or their copies) into the end
            # of FIRST
            first << linked_page
          end
        end
      end

      # Step 5
      first.delete(next_page)
    end
    ptt
  end

  def to_s
    sprintf("Pages in site rooted at %s:\n\t%s",
      @home.uri.to_s,
      @pages.map(&:uri).map(&:path).join("\n\t"))
  end

  private
    def Site.get_pages(root_page, pages)
      existing_uris = pages.map(&:uri)
      new_pages = root_page.link_uris.select do |uri|
        !existing_uris.include?(uri)
      end.collect do |uri|
        Page.new(uri)
      end.uniq
      unless new_pages.empty?
        pages += new_pages
        new_pages.each do |page|
          pages = get_pages(page, pages)
        end
      end
      pages
    end
end

