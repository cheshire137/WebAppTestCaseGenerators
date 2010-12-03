module SharedHTMLTagMethods
  def opposite_type_same_name?(opp_type, other)
	!other.nil? && other.is_a?(opp_type) && name == other.name
  end
end
