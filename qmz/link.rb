require 'uri'

class Link
  attr_reader :uri1, :uri2, :description
  attr_accessor :target_page

  def initialize(uri1, uri2, target_page, desc)
    unless uri1.respond_to?(:get_uniq_parts) && uri2.respond_to?(:get_uniq_parts)
      raise ArgumentError, "Given URIs must respond to .get_uniq_parts() method"
    end
    unless target_page.respond_to? :uri
      raise ArgumentError, "Given target_page must have .uri property"
    end
    unless uri2.get_uniq_parts() == target_page.uri.get_uniq_parts()
      raise ArgumentError,
        "Given target page does not have same URI as given uri2"
    end
    if desc.nil? || !desc.is_a?(String)
      raise ArgumentError, "Expected String description of link, got #{desc.class.name}"
    end
    @uri1 = uri1
    @uri2 = uri2
    @target_page = target_page
    @description = desc
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
    sprintf("%s => %s via %s", @uri1.request_uri, @uri2.request_uri, @description)
  end
end
