require 'rubygems'
require 'treetop'
require 'polyglot'
require 'erb_grammar'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

erb = IO.readlines(ARGV.first).join
parser = ERBGrammarParser.new
parse_result = parser.parse(erb)

if parse_result.nil?
  puts "Error:  could not parse the following ERB: "
  puts erb
  exit
end

pp parse_result.content
