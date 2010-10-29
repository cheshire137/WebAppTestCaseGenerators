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
puts "PFD:"
puts pfd
puts "---------------------------------"
ptt = Site.pfd2ptt(pfd)
puts "PTT:"
puts ptt
printf("PFD equal to PTT?: %s\n", (pfd == ptt) ? 'yes' : 'no')
