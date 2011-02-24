class LinkTransition < Transition
  def initialize(src, snk, c)
    super(src, snk, c)
  end

  def to_s(prefix='')
    sprintf("%sLink Transition\n%s", prefix, super(prefix))
  end
end
