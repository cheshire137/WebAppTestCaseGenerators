base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, '..', 'parser.rb')
require File.join(base_path, 'test_helper.rb')
require File.join(base_path, '..', 'nodes', 'erb_node_extensions.rb')

class SyntaxNodeTest < Test::Unit::TestCase
  include ERBGrammar
  
  def test_same_atomic_section?
	nodes = get_test_nodes()
    # Impose our own order on the elements in the document:
    nodes[:html_tags][0].index = 0
    nodes[:erb_output_tags][0].index = 1
    nodes[:html_tags][1].index = 2
    nodes[:html_tags][2].index = 3
    nodes[:erb_tags][0].index = 4
    nodes[:erb_output_tags][1].index = 5
    nodes[:erb_tags][1].index = 6

    assert nodes[:html_tags][0].same_atomic_section?(nodes[:erb_output_tags][0])
    assert nodes[:erb_output_tags][0].same_atomic_section?(nodes[:html_tags][1])
    assert nodes[:html_tags][1].same_atomic_section?(nodes[:html_tags][2])
    assert !nodes[:html_tags][2].same_atomic_section?(nodes[:erb_tags][0]), "Expected following to not be in same atomic section:\n(#{nodes[:html_tags][2].class.name}) " + nodes[:html_tags][2].to_s + "\n\n(#{nodes[:erb_tags][0].class.name}) " + nodes[:erb_tags][0].to_s
    assert !nodes[:erb_tags][0].same_atomic_section?(nodes[:erb_output_tags][1])
    assert !nodes[:erb_output_tags][1].same_atomic_section?(nodes[:erb_tags][1])
  end

  private
    def get_test_nodes
      doc = Parser.new.parse(fixture('login_index.html'), 'login_index.html.erb')
      form_tag = doc[0]
      assert_equal ERBTag, form_tag.class
      section = form_tag.atomic_sections[0]
      html_tag_1 = section.content[0]
      html_tag_2 = section.content[1]
      html_tag_3 = section.content[3]
      assert_equal HTMLOpenTag, html_tag_1.class, "Tree:\n" + doc.to_s
      assert_equal HTMLOpenTag, html_tag_2.class
      assert_equal HTMLCloseTag, html_tag_3.class
      output_tag_1 = section.content[9]
      output_tag_2 = section.content[15]
      assert_equal ERBOutputTag, output_tag_1.class, output_tag_1.to_s
      assert_equal ERBOutputTag, output_tag_2.class, output_tag_2.to_s
      erb_tag_1 = form_tag
      erb_tag_2 = form_tag.close
      assert_equal ERBTag, erb_tag_2.class
      assert !erb_tag_1.browser_output?
      assert !erb_tag_2.browser_output?
      {:html_tags => [html_tag_1, html_tag_2, html_tag_3],
       :erb_output_tags => [output_tag_1, output_tag_2],
       :erb_tags => [erb_tag_1, erb_tag_2]}
    end
end
