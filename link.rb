require 'uri'

class Link
  attr_reader :uri1, :uri2

  def initialize(uri1, uri2)
    unless uri1.is_a?(URI) && uri2.is_a?(URI)
      raise ArgumentError, "Given URIs must be of type URI"
    end
    @uri1 = uri1
    @uri2 = uri2
  end

  def ==(other)
    other.is_a?(Link) && @uri1 == other.uri1 && @uri2 == other.uri2
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri1.hash ^ @uri2.hash
  end

  def to_s
    sprintf("%s => %s", @uri1.path, @uri2.path)
  end
end
