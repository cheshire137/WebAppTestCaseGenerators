require 'rubygems'
require 'treetop'

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'nodes', 'erb_node_extensions.rb')
Treetop.load(File.join(base_path, 'erb_grammar.treetop'))

class Parser
  @@parser = ERBGrammarParser.new

  def parse(data, file_name)
	puts "Parsing ERB file " + file_name + " with Treetop parser..."
    tree = @@parser.parse data
    if tree.nil?
      raise Exception, "Parse error at offset: #{@@parser.index}"
    end
    tree.initialize_content_and_indices()
	#puts "Pairing HTML tags..."
	#tree.pair_tags
	tree.find_code_units()
    tree.identify_atomic_sections()
    tree.nest_atomic_sections()
    tree.split_branches()
    tree.source_file = file_name
    tree
  end

  def parse_and_compress(data)
	tree = parse(data)
	puts "Compressing content..."
	tree.compress_content
	tree
  end
end
