base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')

class ERBDocumentTest < Test::Unit::TestCase
  def test_delete_at
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	li = doc[6]
	assert_not_nil li
	assert_equal "ERBGrammar::HTMLOpenTag", li.class.name
	assert_equal 'li', li.name
	old_length = doc.length
	deleted_node = doc.nodes.delete_at(6)
	assert_not_equal li, doc[6], "New node in index 6 should not be the same as the one we just deleted"
	new_length = doc.length
	assert_equal old_length-1, new_length, "New length of ERBDocument should be 1 less than old length"
  end

  def test_square_bracket_accessor_fixnum
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
	assert_equal 'for', label.attributes.first.name,
	  "First attribute on label tag should be 'for'"
	end_of_block = doc[doc.length-1]
	assert_not_nil end_of_block
	assert_equal "ERBGrammar::ERBTag", end_of_block.class.name
  end

  def test_square_bracket_accessor_range
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	elements = doc[0..1]
	assert_equal Array, elements.class, "Expected Array return value"
	assert_equal 2, elements.length, "Expected two elements"
	assert_equal "ERBGrammar::ERBTag", elements[0].class.name
	assert_equal "ERBGrammar::HTMLOpenTag", elements[1].class.name
	assert_equal 0, elements[0].index
	assert_equal 1, elements[1].index
  end

  def test_square_bracket_accessor_range2
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	elements = doc[14...15].compact
	assert_equal Array, elements.class
	assert_equal 1, elements.length,
	  "Expected only one result returned from single-element range"
  end

  def test_length
	doc = Parser.new.parse(fixture('login_index.html'))
	assert_not_nil doc
	assert_equal 25, doc.length,
	  "ERB document has 25 different HTML, ERB, and text nodes, #length should return this"
  end
end
