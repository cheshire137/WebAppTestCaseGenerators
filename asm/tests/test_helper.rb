require 'test/unit'

class Test::Unit::TestCase
  BasePath = File.expand_path(File.dirname(__FILE__)).freeze

  # Returns contents of ERB file with the given prefix
  def fixture(file_name_prefix)
	path = File.join(BasePath, 'fixtures', sprintf("%s.erb", file_name_prefix))
	IO.readlines(path).join
  end
end
