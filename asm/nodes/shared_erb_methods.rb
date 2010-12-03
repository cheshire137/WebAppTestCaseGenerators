module SharedERBMethods
  def ==(other)
	super(other) && prop_eql?(other, :code)
  end

  def hash
	prop_hash(:code)
  end

  def ruby_code
	code.content_removing_trims
  end
end
