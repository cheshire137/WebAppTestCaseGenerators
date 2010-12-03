require 'parser.rb'
require 'pp'

unless ARGV.length == 1
  printf("Usage: %s path_to_erb_file\n", $0)
  exit
end

erb = IO.readlines(ARGV.first).join
ast = Parser.new.parse(erb)
pp ast
sections = ast.get_atomic_sections
puts '---------------------'
if sections.empty?
  puts 'No atomic sections!'
end
sections.each do |atomic_section|
  puts atomic_section.to_s
  puts ''
end
