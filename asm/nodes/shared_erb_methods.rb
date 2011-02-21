module SharedERBMethods
  def ==(other)
	super(other) && prop_eql?(other, :ruby_code)
  end

  def hash
	prop_hash(:ruby_code)
  end
end
