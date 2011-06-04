#!/usr/bin/env ruby
# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

root_dir = File.expand_path(File.dirname(__FILE__))
require File.join(root_dir, 'parser.rb')
require 'optparse'
require 'pp'
require File.join(root_dir, 'component_interaction_model.rb')

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
