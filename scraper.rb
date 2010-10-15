#!/usr/bin/env ruby
require 'rubygems'
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
puts site.get_pfd
