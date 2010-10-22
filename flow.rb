require 'link.rb'
require 'page.rb'

class Flow
  attr_reader :page1, :link, :page2

  def initialize(page1, link, page2)
    unless page1.is_a?(Page) && page2.is_a?(Page)
      raise ArgumentError, "Both page1 and page2 must be of type Page"
    end
    unless link.is_a?(Link)
      raise ArgumentError, "Given link must be of type Link"
    end
    unless link.uri1 == page1.uri && link.uri2 == page2.uri
      raise ArgumentError, "Link does not match given pages"
    end
    @page1 = page1
    @link = link
    @page2 = page2
  end

  def ==(other)
    other.is_a?(Flow) && @page1 == other.page1 && @page2 == other.page2 &&
      @link == other.link
  end

  def eql?(other)
    self == other
  end

  def hash
    @page1.hash ^ @link.hash ^ @page2.hash
  end

  def to_s
    sprintf("<%s>\n\tlinks to\n\t<%s>\n\tvia <%s>\n", @page1, @page2, @link)
  end
end
