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

module SharedSexpParsing
  attr_reader :parsed_sexp

  def sexp
    return @parsed_sexp unless @parsed_sexp.nil?
    parser = RubyParser.new
    begin
      @parsed_sexp = parser.parse(ruby_code)
    rescue Racc::ParseError
      @parsed_sexp = :invalid_ruby
    end
    @parsed_sexp
  end
end
