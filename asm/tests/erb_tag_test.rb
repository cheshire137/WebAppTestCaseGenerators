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

base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')

class ERBTagTest < Test::Unit::TestCase
  def test_iteration?
    doc = Parser.new.parse(fixture('iteration.html'), 'iteration.html.erb', URI.parse('/'))
    assert_not_nil doc
    loops = [doc[0], doc[4], doc[5], doc[8], doc[10]]
    loops.each do |loop_tag|
      assert_not_nil loop_tag
      assert_equal "ERBGrammar::ERBTag", loop_tag.class.name
      assert loop_tag.iteration?, "Expected #{loop_tag} to be a loop of some sort"
    end
    non_loops = [doc[13], doc[16]]
    non_loops.each do |non_loop_tag|
      assert_not_nil non_loop_tag
      assert_equal "ERBGrammar::ERBTag", non_loop_tag.class.name
      assert !non_loop_tag.iteration?, "Expected #{non_loop_tag} to not be a loop of any kind"
    end
  end
end
