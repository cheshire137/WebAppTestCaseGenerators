# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module SharedChildrenMethods
  def delete_children_in_range(start_index, end_index)
    should_delete_child = lambda do |el|
      if el.index >= start_index && el.index <= end_index
        #puts "Deleting element #{el}"
        true
      else
        false
      end
    end
    if respond_to?(:atomic_sections) && !self.atomic_sections.nil?
      self.atomic_sections.delete_if(&should_delete_child)
    end
    (@content || []).delete_if(&should_delete_child)
    (@branch_content || []).delete_if do |arr|
      arr.delete_if(&should_delete_child)
      arr.empty?
    end
    #puts "Now there are #{@content.length} children"
    if respond_to?(:parent) && !self.parent.nil? && self.parent.respond_to?(:delete_children_in_range)
      self.parent.delete_children_in_range(start_index, end_index)
    end
    #puts "NOW PARENT IS #{to_s}"
    #puts "--------------------------------\n\n\n"
  end

  def remove_duplicate_children
    return if @content.nil?
    @content.each do |child|
      #puts "Looking at child #{child.class.name}: #{child.range}"
      has_content = child.respond_to?(:content) && !child.content.nil? && !child.content.empty?
      has_close = child.respond_to?(:close) && !child.close.nil?
      if has_content && has_close
        #puts "Deleting range #{child.content.first.index}..#{child.close.index}"
        delete_children_in_range(child.content.first.index, child.close.index)
      end
      if child.respond_to?(:remove_duplicate_children)
        child.remove_duplicate_children()
      end
    end
  end
end
