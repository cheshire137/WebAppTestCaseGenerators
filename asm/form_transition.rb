class FormTransition < Transition
  # TODO: include GET/POST method
  def initialize(src, snk, c)
    super(src, snk, c)
  end

  def to_s(prefix='')
    sprintf("%sForm Transition\n%s", prefix, super(prefix))
  end
end
