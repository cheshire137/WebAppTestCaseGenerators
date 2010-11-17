require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

erb = IO.readlines(ARGV.first).join
ast = Parser.new.parse(erb)
ast.compress_content
printf("Tree with %d nodes:\n", ast.length)
pp ast
