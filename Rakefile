task 'stats' do
  require 'scriptlines'
  get_stats(get_asm_files() + get_qmz_files())
end

task 'asm_stats' do
  require 'scriptlines'
  get_stats(get_asm_files())
end

task 'qmz_stats' do
  require 'scriptlines'
  get_stats(get_qmz_files())
end

def get_stats(files)
  puts ScriptLines.headline
  sum = ScriptLines.new("TOTAL (#{files.size} file(s))")
  
  # Print stats for each file.
  files.each do |fn|
    File.open(fn) do |file|
      script_lines = ScriptLines.new(fn)
      script_lines.read(file)
      sum += script_lines
      puts script_lines
    end
  end

  # Print total stats.
  puts sum
end

def get_asm_files
  files = FileList['asm/nodes/*.rb'] + FileList['asm/*.rb'] + FileList['asm/tests/*.rb'] + FileList['*.rb'] + FileList['asm/*.treetop']
  files -= ['scriptlines.rb']
  files
end

def get_qmz_files
  files = FileList['qmz/*.rb'] + FileList['*.rb']
  files -= ['scriptlines.rb']
  files
end