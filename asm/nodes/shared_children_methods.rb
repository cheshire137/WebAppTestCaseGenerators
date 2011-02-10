module SharedChildrenMethods
  def delete_children_in_range(start_index, end_index)
    #puts "---Deleting children between #{start_index}..#{end_index} from #{self.class.name}"
    #puts "There are #{@content.length} children"
    #puts "FROM PARENT #{to_s}"
    if respond_to?(:atomic_sections) && !self.atomic_sections.nil?
      self.atomic_sections.delete_if do |sec|
        if sec.index >= start_index && sec.index <= end_index
          #puts "Deleting atomic section p#{sec.count}"
          true
        else
          false
        end
      end
    end
    @content.delete_if do |el|
      if el.index >= start_index && el.index <= end_index
        #puts "Deleting element #{el}"
        true
      else
        false
      end
    end
    #puts "Now there are #{@content.length} children"
    if respond_to?(:parent) && !self.parent.nil? && self.parent.respond_to?(:delete_children_in_range)
      self.parent.delete_children_in_range(start_index, end_index)
    end
    #puts "NOW PARENT IS #{to_s}"
    #puts "--------------------------------\n\n\n"
  end
end
