require 'uri_extensions.rb'
require 'page.rb'
require 'link.rb'
require 'pfd.rb'

class Site
  attr_reader :pages, :home

  def initialize(home_page, pages=[])
    unless home_page.is_a? Page
      raise ArgumentError, "Given home page must be a Page instance"
    end
    @home = home_page
    if pages.empty?
      printf("Getting pages for site at %s...\n", @home.uri)
      @pages = Site.get_pages(@home, [@home])
      printf("Got %d pages for site at %s\n", @pages.length, @home.uri)
    else
      @pages = pages
    end
  end

  def Site.from_pfd(pfd)
    unless pfd.is_a? PFD
      raise ArgumentError, "Expected given pfd param to be of type PFD"
    end
    all_pages = pfd.pages
    home_page_uri_desc = pfd.root_uri.get_uniq_parts()
    home_page = all_pages.find do |page|
      page.uri_parts == home_page_uri_desc
    end
    if home_page.nil?
      raise "Cannot extract home page with URI " + pfd.root_uri.to_s +
        " from pages in PFD"
    end
    Site.new(home_page, all_pages - [home_page])
  end

  def get_pfd
    printf("Getting PFD for site %s...\n", @home.uri.to_s)
    pages = [@home, @pages].flatten.uniq
    links = []
    pages.each do |page1|
      page1.link_texts.each do |link_text|
        page2 = pages.find do |page|
          page.uri_parts == link_text.uri_parts
        end
        if page2.nil?
          printf("ERR: cannot find page with URI %s in site\n", link_text.uri.request_uri)
          next
        end
        new_link = Link.new(page1.uri, link_text.uri, page2, link_text.description)
        page1.links << new_link
        links << new_link unless links.include? new_link
      end
    end
    PFD.new(pages, links, @home.uri)
  end

  def Site.pfd2ptt(pfd)
    puts "Converting PFD to PTT..."
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
    def Site.get_pages(root_page, pages, blacklist_uris=[])
      existing_uris = pages.map(&:uri_parts)
      new_pages = []

      # Don't use #each_with_index because we'll also be using #delete_at, and
      # that does weird stuff to the iterator.
      (root_page.link_texts.length-1).downto(0) do |i|
        link_text = root_page.link_texts[i]
        uri = link_text.uri
        uri_desc = link_text.uri_parts
        if blacklist_uris.include?(uri_desc)
          # Current URI is already blacklisted, so remove it from this page
          # and skip ahead
          root_page.delete_link_at(i)
          next
        elsif existing_uris.include?(uri_desc)
          # Current URI is already represented by a Page, so no need to create
          # another Page for it; skip ahead
          next
        end
        html = Page.open_uri(uri)
        if html.nil?
          # Keep track of URIs that give us errors (404 not found, 405 method
          # not allowed, etc.) or that aren't HTML pages, so we don't keep
          # trying to open them
          blacklist_uris << uri_desc
          root_page.link_texts.delete_at(i)
        else
          existing_uris << uri_desc
          new_page = Page.new(uri, html)
          new_pages << new_page
          pages << new_page
        end
      end
      unless new_pages.empty?
        num_new = new_pages.length
        printf("Got %d new Page%s linked from %s\n", num_new,
          num_new == 1 ? '' : 's', root_page.to_s)
        new_pages.each do |page|
          print '.'
          get_pages(page, pages, blacklist_uris)
        end
      end
      pages
    end
end

