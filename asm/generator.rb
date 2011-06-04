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
require 'find'
require File.join(root_dir, 'component_interaction_model.rb')

unless ARGV.length == 2
  printf("Usage: %s path_to_rails_app_root root_url_of_site\n", $0)
  exit
end

rails_root_path = ARGV.shift
begin
  root_url = URI.parse(ARGV.shift)
rescue URI::InvalidURIError => err
  printf("ERROR: could not parse given root URI: %s", err)
  exit
end

app_path = File.join(rails_root_path, 'app')
unless File.exists?(app_path)
  printf("ERROR: expected app directory does not exist at %s", app_path)
  exit
end

views_path = File.join(app_path, 'views')
unless File.exists?(views_path)
  printf("ERROR: expected app/views directory does not exist at %s", views_path)
  exit
end

ERB_FILE_TYPES = ['rhtml', 'erb'].freeze
EXCLUDED_DIRS = ['.svn'].freeze
cims = []

Find.find(views_path) do |path|
  if FileTest.directory?(path)
    dir_name = File.basename(path.downcase)
    if EXCLUDED_DIRS.include?(dir_name)
      Find.prune # Don't look in this directory
    else
      printf("Looking in directory %s\n", path)
    end
  else # Found a file
    file_type = File.basename(path.downcase).split('.').last
    if ERB_FILE_TYPES.include?(file_type)
      erb = IO.readlines(path).join
      if erb.nil? || erb.blank?
        printf("No data in file %s, skipping\n", path)
        next
      end
      ast = Parser.new.parse(erb, path, root_url)
      if ast.nil?
        printf("Could not parse file %s, skipping\n", path)
        next
      end
      expr = ast.component_expression()
      sections = ast.get_atomic_sections()
      trans = ast.get_transitions()
      cim = ComponentInteractionModel.new(root_url, path, expr, sections, trans)
      puts cim.to_s + "\n"
    end
  end
end
