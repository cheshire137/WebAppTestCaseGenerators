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

class AtomicSection
  include SharedMethods
  include ERBGrammar::SharedTransitionMethods
  include SharedChildrenMethods
  include SharedSexpParsing
  include SharedSexpMethods
  extend SharedSexpMethods::ClassMethods
  attr_reader :content, :count, :index

  def initialize(count=1)
	@content = []
	@count = count
    @index = -1
  end

  def can_add_node?(node)
    return false if node.nil?
    return false unless node.browser_output?
    return false if node.index.nil?
    return true if @content.empty?
    last_node = @content.last
	last_node.same_atomic_section?(node) && last_node != node
  end

  def component_expression(seen_children=[])
    unless @content.nil? || @content.empty?
#      puts "Atomic section has content:"
#      pp @content
#      puts "---------"
      # Necessary to check content of atomic section in case it contains an
      # ERBOutputTag that has a render() call, which would be treated as
      # aggregation in the component expression
      child_str = @content.collect do |node|
        if node.respond_to?(:component_expression)
          node.component_expression()
        else
          nil
        end
      end.compact.select do |expr|
        !expr.blank?
      end.join('.')
      unless child_str.blank? || '.' == child_str
        #puts "Component expr. segment from p#@count: " + child_str
        return child_str
      end
    end
    expr = sprintf("p%d", @count)
    #puts "Component expr. segment from p#@count: " + expr
    expr
  end

  def get_local_transitions(source)
    []
  end

  def include?(node)
    return false if @content.nil? || @content.empty?
    return false if node.nil?
    if node.is_a?(ERBGrammar::FakeERBOutput)
      ERBGrammar::FakeERBOutput.new(@content.map(&:text_value), @index) == node
    else
      @content.include?(node)
    end
  end

  def inspect
    to_s
  end

  def range
    return nil if @content.nil? || @content.empty?
    @content.sort! do |a, b|
      a.index <=> b.index
    end
    start_index = @content.first.index
    end_index = @content.last.index
    if start_index.nil? || end_index.nil?
      raise RuntimeError, "Nil start or end index; atomic section has content: " + @content.inspect
    end
    (start_index..end_index)
  end

  # TODO: remove duplication between this and SharedHTMLTagMethods
  def ruby_code
    @content.collect do |child|
      if child.respond_to?(:ruby_code)
        child.ruby_code()
      else
        'puts "' + child.text_value.gsub(/"/, "\\\"") + '"'
      end
    end.join("\n")
  end

  def save(file_path)
    File.open(file_path, 'w') do |file|
      @content.each do |node|
        file.puts node.text_value
      end
    end
  end

  def to_s(indent_level=0)
	to_s_with_prefix(indent_level, sprintf("Atomic Section #%d (indices %s):\n%s",
      @count,
      range().to_s,
      @content.collect do |node|
        node.to_s(indent_level+1)
      end.join("\n")))
  end

  def try_add_node?(node)
	if can_add_node?(node)
      @index = node.index if @content.empty?
	  @content << node
      if node.respond_to?(:atomic_section_count)
        node.atomic_section_count = @count
      end
	  true
	else
	  false
	end
  end
end
