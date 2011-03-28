task 'stats' do
  require 'scriptlines'
  files = FileList['asm/nodes/*.rb'] + FileList['asm/*.rb'] + FileList['asm/tests/*.rb'] + FileList['qmz/*.rb'] + FileList['*.rb']
  files -= ['scriptlines.rb']
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