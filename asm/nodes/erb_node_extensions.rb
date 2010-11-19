module ERBGrammar
  Tab = '  '
  base_path = File.expand_path(File.dirname(__FILE__))
  require File.join(base_path, 'syntax_node.rb')
  require File.join(base_path, 'erb_document.rb')
  require File.join(base_path, 'erb_output_tag.rb')
  require File.join(base_path, 'erb_tag.rb')
  require File.join(base_path, 'html_open_tag.rb')
  require File.join(base_path, 'html_close_tag.rb')
  require File.join(base_path, 'html_self_closing_tag.rb')
  require File.join(base_path, 'html_tag_attributes.rb')
  require File.join(base_path, 'html_tag_attribute.rb')
  require File.join(base_path, 'html_quoted_value.rb')
  require File.join(base_path, 'ruby_code.rb')
  require File.join(base_path, 'text.rb')
  require File.join(base_path, 'whitespace.rb')
  require File.join(base_path, 'html_directive.rb')
end
