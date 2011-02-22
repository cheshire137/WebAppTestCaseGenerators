require 'rubygems'
require 'treetop'

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'nodes', 'erb_node_extensions.rb')
Treetop.load(File.join(base_path, 'erb_grammar.treetop'))

class Parser
  @@parser = ERBGrammarParser.new

  def parse(data, file_name)
    printf("Parsing ERB file %s...\n", file_name)
    tree = @@parser.parse data
    if tree.nil?
      raise Exception, "Parse error at offset: #{@@parser.index}"
    end
    tree.initialize_content()
    tree.split_out_erb_newlines()
    tree.initialize_indices()
    #pp tree
    #puts '-------------'
	#puts "Pairing HTML tags..."
	#tree.pair_tags
	tree.find_code_units()
    tree.identify_atomic_sections()
    tree.nest_atomic_sections()
    tree.split_branches()
    tree.remove_duplicate_children()
    tree.source_file = file_name
    tree.identify_transitions(tree.source_file)
    tree
  end

  def parse_and_compress(data)
	tree = parse(data)
	puts "Compressing content..."
	tree.compress_content()
	tree
  end
end
