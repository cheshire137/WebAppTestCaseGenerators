require 'uri'

class Link
  attr_reader :uri1, :uri2
  attr_accessor :target_page

  def initialize(uri1, uri2, target_page)
    unless uri1.is_a?(URI) && uri2.is_a?(URI)
      raise ArgumentError, "Given URIs must be of type URI"
    end
    unless target_page.is_a? Page
      raise ArgumentError, "Given target page must be of type Page"
    end
    unless uri2 == target_page.uri
      raise ArgumentError, "Given target page does not have same URI as given uri2"
    end
    @uri1 = uri1
    @uri2 = uri2
    @target_page = target_page
  end

  def ==(other)
    other.is_a?(Link) && @uri1 == other.uri1 && @uri2 == other.uri2 &&
      @target_page == other.target_page
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri1.hash ^ @uri2.hash ^ @target_page.hash
  end

  def to_s
    sprintf("%s => %s", @uri1.request_uri, @uri2.request_uri)
  end
end
