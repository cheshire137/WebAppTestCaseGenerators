task 'stats' do
  require 'scriptlines'
  files = (get_asm_files() + get_qmz_files()).uniq
  get_stats(files)
end

task 'asm_stats' do
  require 'scriptlines'
  get_stats(get_asm_files())
end

task 'qmz_stats' do
  require 'scriptlines'
  get_stats(get_qmz_files())
end

task 'code2tex' do
  cmd_prefix = "source-highlight -f latex --output-dir=tex -n --tab=2 --lang-def=ruby.lang"
  files = (get_asm_files() + get_qmz_files()).uniq
  files.each do |fn|
    cmd = cmd_prefix + ' ' + fn
    puts cmd
    `#{cmd}`
  end
end

task 'tex2pdf' do
  file_header = <<HERE
\\documentclass[12pt]{article}
\\usepackage[left=2cm,top=2cm,bottom=2cm,right=2cm,nohead,nofoot]{geometry}
\\begin{document}
HERE
  file_footer = "\\end{document}"
  tex_files = FileList['tex/*.tex'].sort
  header_format = "\\section{%s}"
  combined_file = 'combined_tex.tex'
  puts "Writing combined TeX file..."
  open(combined_file, 'w') do |f|
    f.puts file_header
    tex_files.each do |fn|
      puts "Appending contents of #{fn}..."
      ruby_fn = File.basename(fn, '.tex')
      header_tex = sprintf(header_format, ruby_fn.gsub(/_/, '\\_'))
      f.puts header_tex
      lines = IO.readlines(fn)
      lines.each do |line|
        f.puts line
      end
    end
    f.puts file_footer
  end
  puts "#{combined_file} written"
  pdf_cmd = "pdflatex --shell-escape #{combined_file}"
  puts pdf_cmd
  `#{pdf_cmd}`
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
