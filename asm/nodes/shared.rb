module SharedMethods
  def eql?(other)
	return false unless other.is_a?(self.class)
	self == other
  end

  def index_eql?(other)
	return false if other.nil?
	@index.nil? && other.index.nil? || @index == other.index
  end

  def prop_eql?(other, *property_names)
	property_names.each do |prop_name|
	  return false unless self.send(prop_name) == other.send(prop_name)
	end
	true
  end

  def prop_hash(*property_names)
	hash_code = 0
	property_names << :index unless property_names.include? :index
	property_names.each do |prop_name|
	  prop_value = self.send(prop_name)
	  hash_code = hash_code ^ prop_value unless prop_value.nil?
	end
	hash_code
  end

  def to_s_with_prefix(indent_level=0, suffix='', prefix='  ')
	close_str = if !respond_to?(:close) || @close.nil?
				  ''
				else
				  sprintf("-%d", @close.index)
				end
	sprintf("%s%d%s: %s", prefix * indent_level, @index, close_str, suffix)
  end
end

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

module SharedOpenTagMethods
  def close_str(indent_level=0)
	@close.nil? ? '' : @close.to_s(indent_level)
  end

  def content_str(indent_level=0)
	if @content.nil?
	  ''
	else
	  @content.collect do |el|
		el.to_s(indent_level)
	  end.join("\n") + "\n"
	end + close_str(indent_level)
  end
end

module SharedHTMLTagMethods
  def opposite_type_same_name?(opp_type, other)
	!other.nil? && other.is_a?(opp_type) && name == other.name
  end
end
