require 'test/unit'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')

class ERBDocumentTest < Test::Unit::TestCase
  # def setup
  # end
  # def teardown
  # end
  def test_length
	erb = <<HERE
<% form_tag :action => "try_login" do %>
  <fieldset class="center" id="login">
    <legend>Log In</legend>
    <ol>
      <li>
      	<label for="user_email">User ID/E-mail:</label>
      	<%= text_field "user", "email", :size => 20 %>
      </li>
      <li>
      	<label for="user_password">Password:</label>
      	<%= password_field "user", "password", :size => 20 %>
      </li>
      <li>
      	<%= image_submit_tag 'transparent.png', :id => "login_button" %>
      	<%= link_to( image_tag("transparent.png", {:alt => 'Register'}), 
      	    {:controller => 'login', :action => 'register'}, :id => 'register_button') %>
      </li>
    </ol>
  </fieldset>
<% end %>	
HERE
	doc = Parser.new.parse(erb)
	assert_not_nil doc
	assert_equal 25, doc.length,
	  "ERB document has 25 different HTML, ERB, and text nodes, #length should return this"
  end
end
