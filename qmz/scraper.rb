#!/usr/bin/env ruby
require 'uri'
require 'pfd.rb'
require 'page.rb'
require 'site.rb'

unless ARGV.length.eql? 1
  printf("Usage: %s uri_to_site_home_page\n", $0)
  exit
end

home = Page.new(ARGV.first)
site = Site.new(home)
pfd = site.get_pfd
ptt = Site.pfd2ptt(pfd)
test_paths = ptt.get_test_paths
puts "Test paths:"
test_paths.each do |uris|
  puts uris.map(&:path).join(" => ")
end
