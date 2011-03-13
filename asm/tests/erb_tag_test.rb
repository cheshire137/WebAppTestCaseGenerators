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
