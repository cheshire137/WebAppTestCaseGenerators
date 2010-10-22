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
puts pfd

chain = []
chain << site.home.uri
site.home.links.each do |link|
  if !chain.include? link.uri2
    chain << link.uri2
  end
end

first = []
second = []
chains = []
first << site.home
first.each do |page|
  if !second.include?(page)
    second << page
    page.links.each do |link|
      if first.include?(link.target_page) || second.include?(link.target_page)
        first << link.target_page.dup
      else
        first << link.target_page
      end
    end
  end
  first.delete(page)
end
puts second.map(&:uri).map(&:path).join(" => ")
