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
end