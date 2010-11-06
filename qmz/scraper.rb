#!/usr/bin/env ruby
require 'uri'
require 'pfd.rb'
require 'page.rb'
require 'site.rb'
require 'optparse'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = sprintf("Usage: %s [options]", $0)
  
  options[:uri] = nil
  opts.on('-u', '--uri URI', 'URI of site home page') do |uri|
    options[:uri] = uri
  end

  options[:input_file] = nil
  opts.on('-i', '--input FILE', 'YAML input file with site structure') do |file|
    options[:input_file] = file
  end

  options[:output_file] = nil
  opts.on('-o', '--output FILE', 'YAML site structure will be written here') do |file|
    options[:output_file] = file
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

# Parse command-line parameters and remove all flag parameters from ARGV
optparse.parse!

if options[:uri] && options[:input_file]
  printf("ERR: define only one of --uri, --input\n")
  puts optparse
  exit
elsif options[:uri]
  site = Site.new(Page.new(options[:uri]))
elsif options[:input_file]
  if File.exists? options[:input_file]
    yaml = IO.readlines(options[:input_file]).join
    site = YAML::load(yaml)
    printf("Read site from file %s\n", options[:input_file])
  else
    printf("ERR: given input file %s does not exist\n", options[:input_file])
    exit
  end
else
  # Missing necessary params, print help and exit
  puts optparse
  exit
end

printf("\n%s\n", site.to_s)

if options[:output_file]
  printf("\nWriting site to %s...\n", options[:output_file])
  File.open(options[:output_file], 'w') do |file|
    file.puts YAML::dump(site)
  end
  printf("File successfully written\n")
end

print "\n"

pfd = site.get_pfd
ptt = Site.pfd2ptt(pfd)

puts "Test paths:"
ptt.get_test_paths.each do |uris|
  puts uris.map(&:request_uri).join(" => ")
end
