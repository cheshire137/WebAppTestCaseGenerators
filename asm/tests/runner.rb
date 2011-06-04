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

# See http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html
require 'test/unit'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'erb_tag_test')
require File.join(base_path, 'syntax_node_test')
require File.join(base_path, 'erb_document_test')
