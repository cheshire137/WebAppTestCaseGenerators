#!/usr/bin/env ruby
require 'uri'
require 'pfd.rb'
require 'page.rb'
require 'site.rb'

def print_usage(app_name)
  printf("Usage: %s uri_to_site_home_page [file_to_save_site_structure]\n",
    app_name)
end

if ARGV.length < 1
  print_usage($0)
  exit
elsif ARGV.length > 2
  print_usage($0)
  printf("WARN: ignoring last %d argument(s)\n", ARGV.length - 2)
end

home = Page.new(ARGV.shift)
site = Site.new(home)
printf("\n%s\n", site.to_s)
unless ARGV.empty?
  path = ARGV.shift
  printf("\nWriting site to %s...\n", path)
  File.open(path, 'w') do |file|
    file.puts YAML::dump(site)
  end
  printf("File successfully written\n")
end
print "\n"
pfd = site.get_pfd
ptt = Site.pfd2ptt(pfd)
test_paths = ptt.get_test_paths
puts "Test paths:"
test_paths.each do |uris|
  puts uris.map(&:request_uri).join(" => ")
end
