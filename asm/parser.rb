require 'rubygems'
require 'treetop'
#require 'polyglot'
#require 'erb_grammar'

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'erb_node_extensions.rb')
Treetop.load(File.join(base_path, 'erb_grammar.treetop'))

class Parser
  @@parser = ERBGrammarParser.new

  def parse(data)
    tree = @@parser.parse data
    if tree.nil?
      raise Exception, "Parse error at offset: #{@@parser.index}"
    end
    tree
  end

  def pair_tags(tree)
	mateless = []
	pairs = []
	printf("%d nodes:\n", tree.length)
	tree.each_with_index do |element, i|
	  printf("%d: %s\n", i, element)
	  next unless element.respond_to?(:pair_match?)
	  mate = mateless.find { |el| el.pair_match?(element) }
	  if mate.nil?
		mateless << element
	  else
		pairs << [mate, element]
	  end
	end
	puts "----------"
	puts pairs.map(&:inspect).join("\n")
  end
end
