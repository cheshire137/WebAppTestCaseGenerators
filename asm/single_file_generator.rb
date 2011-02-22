#!/usr/bin/env ruby
require 'parser.rb'
require 'pp'
require 'component_interaction_model.rb'

unless ARGV.length == 2
  printf("Usage: %s path_to_erb_file root_url_of_site\n", $0)
  exit
end

path = ARGV.shift
root_url = ARGV.shift
erb = IO.readlines(path).join
ast = Parser.new.parse(erb, path)
pp ast
expr = ast.component_expression()
sections = ast.get_atomic_sections()
trans = ast.get_transitions()
cim = ComponentInteractionModel.new(root_url, path, expr, sections, trans)
puts cim.to_s + "\n"
