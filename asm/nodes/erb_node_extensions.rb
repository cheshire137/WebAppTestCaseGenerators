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

module ERBGrammar
  BasePath = File.expand_path(File.dirname(__FILE__))
  require File.join(BasePath, 'shared_atomic_section_methods.rb')
  require File.join(BasePath, 'shared_children_methods.rb')
  require File.join(BasePath, 'shared_methods.rb')
  require File.join(BasePath, 'shared_erb_methods.rb')
  require File.join(BasePath, 'shared_html_tag_methods.rb')
  require File.join(BasePath, 'shared_open_tag_methods.rb')
  require File.join(BasePath, 'shared_sexp_methods.rb')
  require File.join(BasePath, 'shared_sexp_parsing.rb')
  require File.join(BasePath, 'shared_transition_methods.rb')
  require File.join(BasePath, 'erb_document.rb')
  require File.join(BasePath, 'erb_output_tag.rb')
  require File.join(BasePath, 'fake_erb_output.rb')
  require File.join(BasePath, 'erb_tag.rb')
  require File.join(BasePath, 'html_open_tag.rb')
  require File.join(BasePath, 'html_close_tag.rb')
  require File.join(BasePath, 'html_self_closing_tag.rb')
  require File.join(BasePath, 'html_tag_attributes.rb')
  require File.join(BasePath, 'html_tag_attribute.rb')
  require File.join(BasePath, 'html_quoted_value.rb')
  require File.join(BasePath, 'ruby_code.rb')
  require File.join(BasePath, 'text.rb')
  require File.join(BasePath, 'whitespace.rb')
  require File.join(BasePath, 'html_directive.rb')
  require File.join(BasePath, 'html_doctype.rb')
  require File.join(BasePath, 'erb_yield.rb')
  require File.join(BasePath, 'syntax_node.rb')
end
