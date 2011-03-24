require 'uri'

class Transition
  attr_reader :source, :sink, :code

  def initialize(src, snk, c)
    if src.nil?
      raise ArgumentError, "Given source of transition cannot be nil"
    end
	if src.is_a?(String)
	  @source = URI.parse(src)
	else
	  @source = src
	end
    if snk.nil? || !snk.is_a?(RailsURL)
      raise ArgumentError, "Given sink of transition cannot be nil, and must be a RailsURL (got #{snk.class.name})"
    end
    @sink = snk
    if c.nil? || !c.is_a?(String) || c.blank?
      raise ArgumentError, "Given transition code cannot be blank or nil, and must be a String (got #{c.class.name})"
    end
    @code = c
  end

  def inspect
    to_s
  end

  def to_s(prefix='')
    tab = '  '
    sprintf("%s%s<%s> --> <%s>\n%s%sUnderlying code:\n%s%s%s%s",
            tab, prefix, @source, @sink, prefix, tab,
            prefix, tab, tab, (@code || '').strip)
  end
end
