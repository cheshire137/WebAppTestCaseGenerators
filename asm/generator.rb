#!/usr/bin/env ruby
require 'parser.rb'
require 'find'
require 'component_interaction_model.rb'

unless ARGV.length == 2
  printf("Usage: %s path_to_rails_app_root root_url_of_site\n", $0)
  exit
end

rails_root_path = ARGV.shift
root_url = ARGV.shift

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
      ast = Parser.new.parse(erb, path)
      expr = ast.component_expression()
      sections = ast.get_atomic_sections()
      trans = ast.get_transitions()
      cim = ComponentInteractionModel.new(root_url, path, expr, sections, trans)
      puts cim.to_s + "\n"
    end
  end
end
