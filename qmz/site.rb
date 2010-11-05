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
    printf("Getting pages for site at %s...\n", @home.uri)
    @pages = Site.get_pages(@home, [@home])
    printf("Got %d pages for site at %s\n", @pages.length, @home.uri)
  end

  def get_pfd
    pages = [@home, @pages].flatten.uniq
    links = []
    pages.each do |page1|
      page1.link_uris.each do |uri|
        page2 = pages.find { |page| page.uri == uri }
        if page2.nil?
          printf("ERR: cannot find page with URI %s in site\n", uri.request_uri)
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
      @pages.map(&:uri).map(&:request_uri).join("\n\t"))
  end

  private
    def Site.get_pages(root_page, pages)
      existing_uris = pages.collect do |page|
        [page.uri.scheme, page.uri.host, page.uri.request_uri]
      end
      new_pages = root_page.link_uris.select do |uri|
        # Compare scheme (e.g. http), host (e.g. google.com), and request_uri,
        # which includes parameters such as ?query=whee but not #comments
        !existing_uris.include?([uri.scheme, uri.host, uri.request_uri])
      end.uniq.collect do |uri|
        html = Page.open_uri(uri)
        if !html.nil? && html.content_type == 'text/html'
          Page.new(uri, html)
        end
      end.compact.uniq
      unless new_pages.empty?
        pages += new_pages
        new_pages.each do |page|
          pages = get_pages(page, pages)
        end
      end
      pages
    end
end

