#!/usr/bin/env ruby
require 'parser.rb'
require 'optparse'
require 'pp'
require 'component_interaction_model.rb'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = sprintf("Usage: %s [options]", $0)

  options[:debug] = false
  $DEBUG = false
  opts.on('-d', '--debug', 'Turn debug messages on') do
    options[:debug] = true
    $DEBUG = true
  end
end

# Parse command-line parameters and remove all flag parameters from ARGV
optparse.parse!

unless ARGV.length == 2
  printf("Usage: %s [-d] path_to_erb_file root_url_of_site\n", $0)
  exit
end

path = ARGV.shift
begin
  root_url = URI.parse(ARGV.shift)
rescue URI::InvalidURIError => err
  printf("ERROR: could not parse given root URI: %s", err)
  exit
end
erb = IO.readlines(path).join
ast = Parser.new.parse(erb, path, root_url, options[:debug])
pp ast
expr = ast.component_expression()
sections = ast.get_atomic_sections()
trans = ast.get_transitions()
cim = ComponentInteractionModel.new(root_url, path, expr, sections, trans)
puts cim.to_s + "\n"
