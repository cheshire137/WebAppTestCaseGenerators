require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

erb = IO.readlines(ARGV.first).join
ast = Parser.new.parse(erb)
pp ast
puts '--------------------------'
code_chunks = ast.extract_ruby_code
code_chunks.each do |code|
  puts code.to_s
end
