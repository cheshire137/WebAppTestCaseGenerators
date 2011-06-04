#!/usr/bin/env ruby
# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'find'

license_text_path = 'license.txt'
license_path = 'license.rb'
if File.exists?(license_path)
  File.delete(license_path)
end
license_lines = IO.readlines(license_text_path)
File.open(license_path, 'w') do |f|
  license_lines.each do |line|
    f.write('# ' + line)
  end
  f.write("\n")
end
puts "Wrote file #{license_path}"
license_comments = File.read(license_path)
inc_dirs = ['.', 'asm', 'qmz', 'nodes', 'tests']
inc_types = ['rb']
exc_paths = [license_path, 'scriptlines.rb']
Find.find('.') do |path|
  name = File.basename(path.downcase)
  if FileTest.directory?(path)
    if inc_dirs.include?(name)
      printf("Looking in directory %s\n", path)
    else
      Find.prune
    end
  else # found a file
    file_type = name.split('.').last
    if inc_types.include?(file_type) && !exc_paths.include?(name)
      file_content = File.read(path)
      puts "Prepending license to file #{path}"
      File.open(path, 'w') do |f|
        f << license_comments
        f << file_content
      end
    end
  end
end
