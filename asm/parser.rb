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

require 'rubygems'
require 'treetop'

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'nodes', 'erb_node_extensions.rb')
Treetop.load(File.join(base_path, 'erb_grammar.treetop'))

class Parser
  @@parser = ERBGrammarParser.new

  def parse(data, file_name, root_url, debug_on=false)
    printf("Parsing ERB file %s...\n", file_name)
    tree = @@parser.parse data
    unless tree.nil?
      puts "Initializing content..." if debug_on
      tree.initialize_content()
      puts "Splitting out ERB newlines..." if debug_on
      tree.split_out_erb_newlines()
      puts "Initializing indices..." if debug_on
      tree.initialize_indices()
      #pp tree
      #puts '-------------'
      #puts "Pairing HTML tags..."
      #tree.pair_tags
      puts "Setting up code units..." if debug_on
      tree.setup_code_units()
      puts "Identifying atomic sections..." if debug_on
      tree.identify_atomic_sections()
      puts "Nesting atomic sections..." if debug_on
      tree.nest_atomic_sections()
      puts "Splitting branches..." if debug_on
      tree.split_branches()
      puts "Removing duplicate children..." if debug_on
      tree.remove_duplicate_children()
      puts "Identifying transitions..." if debug_on
      src_rails_url = RailsURL.from_path(file_name, root_url)
      if src_rails_url.nil?
        printf("Could not interpret path %s as a Rails URL, skipping transition identification\n", file_name)
      else
        tree.identify_transitions(src_rails_url, root_url)
      end
      tree.source_file = file_name
    end
    tree
  rescue Racc::ParseError => err
    printf("Failed to parse %s at offset %d: %s\n", file_name, @@parser.index, err)
  rescue SyntaxError => err
    printf("Failed to parse %s at offset %d: %s\n", file_name, @@parser.index, err)
  end

  def parse_and_compress(data)
	tree = parse(data)
	puts "Compressing content..."
	tree.compress_content()
	tree
  end
end
