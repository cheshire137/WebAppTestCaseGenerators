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
