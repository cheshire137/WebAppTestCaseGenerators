class LinkTransition < Transition
  def initialize(src, snk, c)
    super(src, snk, c)
  end

  def to_s(prefix='')
    sprintf("%sLink Transition\n%s\t<%s> --> <%s>\n%s\tUnderlying code:\n%s\t\t%s", prefix, prefix, @source, @sink, prefix, prefix, @code)
  end
end
