class FormTransition < Transition
  # TODO: include GET/POST method
  def initialize(src, snk, c)
    super(src, snk, c)
  end

  def to_s(prefix='')
    sprintf("%sForm Transition\n%s\t<%s> --> <%s>\n%s\tUnderlying code:\n%s\t\t%s", prefix, prefix, @source, @sink, prefix, prefix, @code)
  end
end
