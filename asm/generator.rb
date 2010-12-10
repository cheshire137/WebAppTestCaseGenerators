require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

file_name = ARGV.first
erb = IO.readlines(file_name).join
ast = Parser.new.parse(erb, file_name)
pp ast
puts '--------------------'
puts ast.component_expression
#root_dir = File.expand_path(File.dirname(__FILE__))
#files = ast.save_atomic_sections(root_dir)
