#!/usr/bin/env ruby
require 'uri'
require 'pfd.rb'
require 'page.rb'
require 'site.rb'

def print_usage(app_name)
  printf("Usage: %s [uri_to_site_home_page] [file_to_load_or_save_site_structure]\n",
    app_name)
  printf("You must provide either a URI to the site's home page or the path to an\n" +
    "existing file from which the site structure can be read.  If you provide\n" +
    "the URI, it is optional that you provide a path; if the path is provided,\n" +
    "it will be overwritten with the site structure taken from the given URI.\n")
end

if ARGV.length < 1
  print_usage($0)
  exit
elsif ARGV.length > 2
  print_usage($0)
  printf("WARN: ignoring last %d argument(s)\n", ARGV.length - 2)
end

uri_or_path = ARGV.shift
if File.exists? uri_or_path
  yaml = IO.readlines(uri_or_path).join
  site = YAML::load(yaml)
  printf("Read site from file %s\n", uri_or_path)
else
  site = Site.new(Page.new(uri_or_path))
end
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
