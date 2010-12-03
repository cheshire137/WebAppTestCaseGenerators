require 'rubygems'
require 'ruby_parser'
require 'atomic_section.rb'

module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
	include Enumerable
	attr_reader :nodes, :initialized_nodes
	@@parser = RubyParser.new

	def [](obj)
	  if obj.is_a?(Fixnum)
		each_with_index do |el, i|
		  return el if el.index == obj || i == obj
		end
	  elsif obj.respond_to?(:include?)
		i = 0
		select do |el|
		  is_nil = el.index.nil?
		  index_match = !is_nil && obj.include?(el.index)
		  i_match = is_nil && obj.include?(i)
		  result = index_match || i_match
		  i += 1
		  result
		end
	  else
		nil
	  end
	end

	def compress_content
	  # Need to go in reverse lest we end up end up with unnested content
	  (length-1).downto(0) do |i|
		element = self[i]
		next unless element.respond_to?(:close) &&
					!element.close.nil? &&
					element.respond_to?(:content)
		# element is open tag
		range = element.index+1...element.close.index
		content = self[range].compact
		next if content.nil? || content.empty?
		element.content = content.dup 
		content.each do |consumed_el|
		  delete_node_check_size(consumed_el)
		end
		# Closing element is not part of the content, but it no longer
		# needs to appear as a separate element in the tree
		delete_node_check_size(element.close)
	  end
	end

	def each
	  if @initialized_nodes
		@nodes.each { |n| yield n }
	  else
		yield node
		if !x.nil? && x.respond_to?(:each)
		  x.each { |other| yield other }
		end
	  end
	end

	def find_code_units
	  code_elements = ERBDocument.extract_ruby_code_elements(@nodes)
	  ERBDocument.find_code_units(code_elements)
	end

	def get_atomic_sections
      sections = []
      section = AtomicSection.new(1)
      each do |child_node|
        puts "For atomic section #{section.count}, looking at #{child_node}"
        if section.try_add_node?(child_node)
          puts 'Successfully added to atomic section'
        else
          puts 'Could not add node, creating new atomic section'
          sections << section
          section = AtomicSection.new(section.count+1)
          unless section.try_add_node?(child_node)
            raise "Could not add node #{child_node} to empty atomic section"
          end
        end
        puts ''
      end
      sections
    end

    def initialize_nodes_and_indices
      @initialized_nodes = false
	  @nodes = []
      each_with_index do |element, i|
        next unless element.respond_to? :index
		@nodes << element
        element.index = i
      end
	  @initialized_nodes = true
    end

    def inspect
      to_s
    end

	# Returns the number of HTML, ERB, and text nodes in this document
	def length
	  if @initialized_nodes
		@nodes.length
	  else
		1 + (x.respond_to?(:length) ? x.length : 0)
	  end
	end

    def pair_tags
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :pair_match?
        # Find first matching mate for this element in the array of mateless
        # elements.  First matching mate will be latest added element.
        mate = mateless.find { |el| el.pair_match?(element) }
        if mate.nil?
          # Add mate to beginning of mateless array, so array is sorted by
          # most-recently-found to earliest-found.
          mateless.insert(0, element)
        else
          if mate.respond_to? :close
            mate.close = element
            mateless.delete(mate)
          else
            raise "Mate found out of order: " + mate.to_s + ", " + element.to_s
          end
        end
      end
    end

    def to_s(indent_level=0)
	  map(&:to_s).select { |str| !str.blank? }.join("\n")
    end

	private
	  def delete_node_check_size(node_to_del)
		size_before = @nodes.length
		del_node_str = node_to_del.to_s
		@nodes.delete(node_to_del)
		if size_before - @nodes.length > 1
		  raise "Deleted more than one node equaling\n" + del_node_str
		end
	  end
	  def ERBDocument.extract_ruby_code_elements(nodes)
		code_els = []
		code_classes = [ERBTag, ERBOutputTag]
		nodes.each do |el|
		  code_els << el if code_classes.include? el.class
		  if el.respond_to?(:content) && !(content = el.content).nil?
			# Recursively check content of this node for other code elements
			code_els += extract_ruby_code_elements(content)
		  end
		end
		code_els
	  end

	  def ERBDocument.find_code_units(code_elements)
		num_elements = code_elements.length
		start_index = 0
		end_index = 0
		while end_index < num_elements
		  range = start_index..end_index
		  unit_elements = code_elements[range]
		  unit_lines = unit_elements.map(&:ruby_code)
		  end_index += 1
		  begin
			sexp = @@parser.parse(unit_lines.join("\n"))
			setup_code_unit(unit_elements, sexp)
			start_index = end_index
		  rescue Racc::ParseError
		  end
		end
	  end

	  def ERBDocument.setup_code_unit(unit_elements, sexp)
		len = unit_elements.length
        return if len < 2
		opening = unit_elements.first
		unless opening.is_a? ERBTag
		  raise "Expected opening element of code unit to be an ERBTag"
		end
		opening.close = unit_elements.last
		opening.content = unit_elements[1...len-1]
		opening.sexp = sexp
		find_code_units(opening.content)
	  end
  end
end
