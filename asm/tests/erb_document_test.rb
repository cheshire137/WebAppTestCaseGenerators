base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')

class ERBDocumentTest < Test::Unit::TestCase
  def test_square_bracket_accessor
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	form = doc[0]
	assert_not_nil form
	assert_equal "ERBGrammar::ERBTag", form.class.name
	label = doc[7]
	assert_not_nil label
	assert_equal "ERBGrammar::HTMLOpenTag", label.class.name
	assert_equal 1, label.attributes.length,
	  "Should be one attribute on HTML label tag: " + label.to_s
	end_of_block = doc[doc.length-1]
	assert_not_nil end_of_block
	assert_equal "ERBGrammar::ERBTag", end_of_block.class.name
  end

  def test_length
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	assert_equal 25, doc.length,
	  "ERB document has 25 different HTML, ERB, and text nodes, #length should return this"
  end
end
