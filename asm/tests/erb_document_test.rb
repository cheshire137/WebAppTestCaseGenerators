base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')

class ERBDocumentTest < Test::Unit::TestCase
  def test_form_tag_component_expression
    assert_component_expression(fixture('login_index.html'),
                                'login_index.html.erb',
                                'p1')
  end

  def test_javascript_component_expression
    assert_component_expression(fixture('javascript.html'),
                                'javascript.html.erb',
                                '(p1|NULL)')
  end

  def test_nested_unequal_ifs_component_expression
    assert_component_expression(fixture('nested_unequal_ifs.html'),
                                'nested_unequal_ifs.html.erb',
                                "(((p1|NULL).p2)|p3)")
  end

  def test_nested_aggregation_component_expression
    assert_component_expression(fixture('game_index2.html'),
                                'game_index2.html.erb',
                                "p1.(p2|(p3.p4*.p5))*.p6")
  end

  def test_nested_aggregation_selection_component_expression
    assert_component_expression(fixture('game_index1.html'),
                                'game_index1.html.erb',
                                '(NULL|(p1.(p2|(p3.p4*.p5))*.p6))')
  end

  def test_nested_if_and_aggregation_component_expression
    assert_component_expression(fixture('top_records.html'),
                                'top_records.html.erb',
                                'p1.(p2|(p3.{p4}.p5)).p6.(p7|(p8.{p9}.p10)).p11')
  end

  def test_nested_if_and_loop_component_expression
    assert_component_expression(fixture('_finished.html'),
                                '_finished.html.erb',
                                '((p1|p2)|NULL).(NULL|p3).(NULL|p4).p5.p6*.p7')
  end

  def test_delete_node
	doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb')
	assert_not_nil doc
	form = doc[0]
	assert_not_nil form
	assert_equal "ERBGrammar::ERBTag", form.class.name
	old_length = doc.length
	deleted_node = doc.content.delete(form)
    assert_equal form, deleted_node, "Expected returned deleted_node to match form"
	assert_not_equal form, doc[0], "New node in index 0 should not be the same as the one we just deleted"
	new_length = doc.length
	assert_equal old_length-1, new_length, "New length of ERBDocument should be 1 less than old length"
  end

  def test_nested_atomic_section
    doc = Parser.new.parse(fixture('_finished.html'), '_finished.html.erb')
    assert_not_nil doc
    # The code in question:
    # <% #Check the state of the game and write out the winners, losers, and drawers.
    #    #Then display the final scores.
    #    if @winner %>
    #     <% if @winner.id == session[:user][:id] %>
    #         <p class="game_result_positive">You won!</p>
    #     <% else %>
    #         <p class="game_result_negative"><%= @winner.email %> won!</p>
    #     <% end %>
    # <% end %>
    if_winner = doc[0]
    assert_not_nil if_winner
    assert_equal "ERBGrammar::ERBTag", if_winner.class.name, "Wrong type of node in slot 0 of ERBDocument"
    assert_not_nil if_winner.content, "Nil content in if-winner ERBTag"
    nodes = if_winner.get_sections_and_nodes()
    assert_equal 1, nodes.length, "Expected one ERBTag child node of if-winner ERBTag"
    if_winner_equal = nodes.first
    sections = if_winner_equal.get_sections_and_nodes().select do |child|
      child.is_a?(AtomicSection)
    end
    assert_equal 1, sections.length, "Expected one atomic section child of if-winner-equal ERBTag: " + sections.inspect
    assert_not_nil if_winner_equal.true_content, "Expected non-nil true_content for if-winner-equal ERBTag"
    assert_not_nil if_winner_equal.false_content, "Expected non-nil false_content for if-winner-equal ERBTag"
    else_tag = if_winner_equal.close
    assert_not_nil else_tag, "Expected 'else' to be close of: " + if_winner_equal.to_s
    assert_equal "else", else_tag.ruby_code
    else_sections = else_tag.get_sections_and_nodes().select do |child|
      child.is_a?(AtomicSection)
    end
    assert_equal 1, else_sections.length, "Expected one atomic section child of else tag: " + else_sections.inspect
  end

  def test_square_bracket_accessor_fixnum
	doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb')
	assert_not_nil doc
	form = doc[0]
	assert_not_nil form
	assert_equal "ERBGrammar::ERBTag", form.class.name
	label = form.content.find { |c| 7 == c.index }
	assert_not_nil label
	assert_equal "ERBGrammar::HTMLOpenTag", label.class.name
    assert_equal "label", label.name
	assert_equal 1, label.attributes.length,
	  "Should be one attribute on HTML label tag: " + label.to_s
	assert_equal 'for', label.attributes.first.name,
	  "First attribute on label tag should be 'for'"
	end_of_block = doc[doc.length-1]
	assert_not_nil end_of_block
	assert_equal "ERBGrammar::ERBTag", end_of_block.class.name
  end

  def test_square_bracket_accessor_range
	doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb')
	assert_not_nil doc
	elements = doc[0..1]
	assert_equal Array, elements.class, "Expected Array return value"
	assert_equal 1, elements.length, "Expected one element"
	assert_equal "ERBGrammar::ERBTag", elements[0].class.name
	assert_equal 0, elements[0].index
  end

  def test_length
	doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb')
	assert_not_nil doc
	assert_equal 1, doc.length,
	  "ERB document has all nodes nested within a form_tag, so doc should have length 1"
  end

  private
    def assert_component_expression(erb, file_name, expected)
      doc = Parser.new.parse(erb, file_name)
      assert_not_nil doc
      actual = doc.component_expression()
      assert_equal expected, actual, "Wrong component expression for " + file_name
    end
end
