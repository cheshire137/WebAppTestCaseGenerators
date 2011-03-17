#!/usr/bin/env ruby
require 'uri'
require 'optparse'
require 'pfd.rb'
require 'page.rb'
require 'site.rb'

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
  opts.on('-o', '--output FILE',
    'YAML site structure will be written here') do |file|
    options[:output_file] = file
  end

  options[:ptt_file] = nil
  opts.on('-p', '--ptt FILE', 'File where PTT will be saved') do |file|
    options[:ptt_file] = file
  end

  options[:test_paths_file] = nil
  opts.on('-t', '--tests FILE',
    'File in which generated test paths will be stored') do |file|
    options[:test_paths_file] = file
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

# Parse command-line parameters and remove all flag parameters from ARGV
optparse.parse!

should_generate_ptt = true
if options[:uri] && options[:input_file]
  print "ERR: define only one of --uri, --input\n"
  puts optparse
  exit
elsif options[:uri]
  puts "Got URI #{options[:uri]}"
  site = Site.new(Page.new(options[:uri]))
elsif options[:input_file]
  if File.exists? options[:input_file]
    yaml = IO.readlines(options[:input_file]).join
    user_input = YAML::load(yaml)
    if user_input.is_a? Site
      site = user_input
      printf("Read site from file %s\n", options[:input_file])
    elsif user_input.is_a? PFD
      ptt = user_input
      site = Site.from_pfd(ptt)
      should_generate_ptt = false
      printf("Read PTT from file %s\n", options[:input_file])
    else
      printf("ERR: could not get a site or a PTT from the given input " +
        "file: %s\n", options[:input_file])
      exit
    end
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
  puts "File successfully written"
end
print "\n"

if should_generate_ptt
  pfd = site.get_pfd()
  ptt = Site.pfd2ptt(pfd)
end

if options[:ptt_file] && !ptt.nil?
  printf("\nWriting PTT to %s...\n", options[:ptt_file])
  File.open(options[:ptt_file], 'w') do |file|
    file.puts YAML::dump(ptt)
  end
  print "File successfully written\n\n"
end

test_paths = ptt.get_test_paths()

if options[:test_paths_file] && !test_paths.empty?
  printf("Writing test paths to %s...\n", options[:test_paths_file])
  File.open(options[:test_paths_file], 'w') do |file|
    test_paths.each do |uris|
      file.puts uris.map(&:to_s).join(" => ")
    end
  end
  print "File successfully written\n\n"
end

dir_name = site.home.uri_parts.join('.').gsub(/\//, '_').chomp('_').chomp('.')
Dir.mkdir(dir_name)
FileUtils.copy('screen.css', dir_name)
html_path = dir_name + '/index.html'
printf("Writing HTML file with test paths to %s...\n", html_path)
File.open(html_path, 'w') do |file|
  file.puts PFD.to_html(site.home.uri, test_paths)
end
puts "File successfully written"
