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
