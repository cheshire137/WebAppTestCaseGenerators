require File.join(File.expand_path(File.dirname(__FILE__)), 'uri_extensions.rb')

class LinkText
  attr_reader :uri, :uri_parts, :description

  def initialize(u, desc)
    if u.nil? || !u.is_a?(URI)
      raise ArgumentError, "Expected URI, got #{u.class.name}"
    end
    @uri = u
    if desc.nil? || !desc.is_a?(String)
      raise ArgumentError, "Expected String of link description, got #{desc.class.name}"
    end
    @description = desc
    @uri_parts = @uri.get_uniq_parts()
  end

  def ==(other)
    other.is_a?(LinkText) && @uri_parts == other.uri_parts && @description == other.description
  end

  def <=>(other)
    @description <=> other.description
  end

  def eql?(other)
    self == other
  end

  def hash
    @uri.hash ^ @description.hash
  end
end
