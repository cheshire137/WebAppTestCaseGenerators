#!/usr/bin/env ruby
require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

path = ARGV.first
erb = IO.readlines(path).join
ast = Parser.new.parse(erb, path)
pp ast
expr = ast.component_expression()
puts expr
