task 'stats' do
  require 'scriptlines'
  files = (get_asm_files() + get_qmz_files() + get_shared_files()).uniq
  get_stats(files)
end

task 'asm_stats' do
  require 'scriptlines'
  get_stats(get_asm_files() + get_shared_files())
end

task 'qmz_stats' do
  require 'scriptlines'
  get_stats(get_qmz_files() + get_shared_files())
end

task 'code2tex' do
  del_tex_cmd = "rm tex/asm/*.tex; rm tex/qmz/*.tex; rm tex/shared/*.tex"
  puts del_tex_cmd
  `#{del_tex_cmd}`
  {'asm' => get_asm_files(),
   'qmz' => get_qmz_files(),
   'shared' => get_shared_files()}.each do |dir_name, files|
    puts "Converting #{dir_name} files to TeX..."
    cmd_prefix = "source-highlight -f latexcolor --output-dir=tex/#{dir_name} -n --tab=2 --lang-def=ruby.lang"
    files.each do |fn|
      cmd = cmd_prefix + ' ' + fn
      puts cmd
      `#{cmd}`
    end
  end
end

task 'tex2pdf' do
  file_header = <<HERE
\\documentclass[11pt]{article}
\\usepackage[left=2cm,top=2cm,bottom=2cm,right=2cm,nohead,nofoot]{geometry}
\\usepackage[usenames,dvipsnames]{color}
\\usepackage[pdfborder={0 0 0}]{hyperref}  
\\hypersetup{pdfborder=0 0 0}
\\begin{document}
\\tableofcontents
HERE
  file_footer = "\\end{document}"
  tex_files = {'Atomic Section Model Tool' => FileList['tex/asm/*.tex'],
    'Qian, Miao, Zeng Model Tool' => FileList['tex/qmz/*.tex'],
    'Shared Files' => FileList['tex/shared/*.tex']}
  combined_file = 'combined_tex.tex'
  del_combined_tex_cmd = "rm #{combined_file}"
  puts del_combined_tex_cmd
  `#{del_combined_tex_cmd}`
  puts "Writing combined TeX file..."
  open(combined_file, 'w') do |f|
    f.puts file_header
    tex_files.each do |files_header, files|
      puts "Appending #{files_header} files..."
      f.puts sprintf("\\section{%s}", files_header)
      files.each do |fn|
        ruby_fn = File.basename(fn, '.tex')
        f.puts sprintf("\\subsection{%s}", ruby_fn.gsub(/_/, '\\_'))
        f.puts sprintf("\\input{%s}", fn)
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
  FileList['asm/nodes/*.rb'] + FileList['asm/*.rb'] + FileList['asm/tests/*.rb'] + FileList['asm/*.treetop']
end

def get_qmz_files
  FileList['qmz/*.rb']
end

def get_shared_files
  files = FileList['*.rb']
  files -= ['scriptlines.rb']
  files
end
