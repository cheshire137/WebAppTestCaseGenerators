require 'rubygems'
require 'ruby_parser'

module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
	include Enumerable
	attr_reader :nodes, :initialized_nodes

	def [](obj)
	  if obj.is_a?(Fixnum)
		each_with_index do |el, i|
		  return el if el.index == obj || i == obj
		end
	  elsif obj.respond_to?(:include?)
		i = 0
		select do |el|
		  index_match = !el.index.nil? && obj.include?(el.index)
		  i_match = el.index.nil? && obj.include?(i)
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
		  size_before = @nodes.length
		  @nodes.delete(consumed_el)
		  if size_before - @nodes.length > 1
			raise "Deleted more than one content node"
		  end
		end
		# Closing element is not part of the content, but it no longer
		# needs to appear as a separate element in the tree
		size_before = @nodes.length
		@nodes.delete(element.close)
		if size_before - @nodes.length > 1
		  raise "Deleted more than one closing node"
		end
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
	  puts '-----------------------'
	  puts "Code lines:\n" + code_elements.map(&:ruby_code).join("\n")
	  puts '-----------------------'
	  ERBDocument.find_code_units(code_elements)
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
	  @initialized_nodes = false
	  @nodes = []
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :index
		@nodes << element
        element.index = i
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
	  @initialized_nodes = true
    end

    def to_s(indent_level=0)
	  Tab * indent_level + map(&:to_s).select { |str| !str.blank? }.join("\n")
    end

	private
	  def ERBDocument.extract_ruby_code_elements(nodes)
		code_els = []
		code_classes = [ERBTag, ERBOutputTag]
		nodes.each do |el|
		  if code_classes.include? el.class
			code_els << el
		  end
		  if el.respond_to?(:content) && !el.content.nil?
			code_els += extract_ruby_code_elements(el.content)
		  end
		end
		code_els
	  end

	  def ERBDocument.find_code_units(code_elements)
		puts "Finding code units in:\n\t" + code_elements.map(&:to_s).join("\n\t")
		num_elements = code_elements.length
		start_index = 0
		end_index = 0
		parser = RubyParser.new # TODO: store in class var?
		while end_index < num_elements
		  range = start_index..end_index
		  puts "Lines " + range.to_a.join(', ')
		  unit_elements = code_elements[range]
		  unit_lines = unit_elements.map(&:ruby_code)
		  begin
			sexp = parser.parse(unit_lines.join("\n"))
			setup_code_unit(unit_elements, sexp)
			end_index += 1
			start_index = end_index
		  rescue Racc::ParseError
			end_index += 1
		  end
		end
	  end

	  def ERBDocument.setup_code_unit(unit_elements, sexp)
		if unit_elements.length < 2
		  return
		end
		opening = unit_elements.first
		unless opening.is_a? ERBTag
		  raise "Expected opening element of code unit to be an ERBTag"
		end
		opening.is_opening = true
		opening.close = unit_elements.last
		opening.close.is_closing = true
		opening.content = unit_elements[1...unit_elements.length-1]
		opening.sexp = sexp
		puts "Found unit:\n\t" + opening.to_s
		find_code_units(opening.content)
	  end
  end
end
