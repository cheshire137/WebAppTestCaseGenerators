#!/usr/bin/env ruby
require 'shared.rb'
include QmzScraperShared

unless ARGV.length.eql? 1
  print_help()
  exit
end

home = Page.new(ARGV.first)
puts home
