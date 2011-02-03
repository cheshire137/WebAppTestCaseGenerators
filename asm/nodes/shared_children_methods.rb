module SharedChildrenMethods
  def delete_children_in_range(start_index, end_index)
    #puts "Deleting children between #{start_index}..#{end_index} from #{self.class.name}"
    if respond_to?(:atomic_sections)
      self.atomic_sections.delete_if { |sec| sec.index >= start_index && sec.index <= end_index }
    end
    @content.delete_if { |el| el.index >= start_index && el.index <= end_index }
    if respond_to?(:parent) && !self.parent.nil? && self.parent.respond_to?(:delete_children_in_range)
      self.parent.delete_children_in_range(start_index, end_index)
    end
  end
end
