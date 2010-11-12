require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

erb = IO.readlines(ARGV.first).join
ast = Parser.new.parse(erb)
printf("Tree with %d nodes:\n", ast.length)
pp ast
puts '----------------------------'
ast.compress_content
pp ast
