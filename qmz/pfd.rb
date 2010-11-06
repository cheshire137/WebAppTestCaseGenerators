require 'erb'
require 'page.rb'
require 'link.rb'

class PFD
  PFDTemplateFile = 'pfd_template.html.erb'.freeze
  attr_reader :pages, :links, :root_uri

  def initialize(pages, links, root_uri)
    unless pages.respond_to? :each
      raise ArgumentError, "Given pages arg must be enumerable"
    end
    unless links.respond_to? :each
      raise ArgumentError, "Given links arg must be enumerable"
    end
    unless root_uri.is_a? URI
      raise ArgumentError, "Expected given root_uri to be of type URI"
    end
    @pages = pages
    @links = links
    @root_uri = root_uri
  end

  def ==(other)
    return false unless other.is_a?(PFD)
    if @pages.length != other.pages.length ||
       @links.length != other.links.length
      return false
    end
    @pages.each do |page|
      return false unless other.pages.include?(page)
    end
    other.pages.each do |page|
      return false unless @pages.include?(page)
    end
    @links.each do |link|
      return false unless other.links.include?(link)
    end
    other.links.each do |link|
      return false unless @links.include?(link)
    end
    return true
  end

  def eql?(other)
    self == other
  end

  def get_test_paths
    preorder(@pages[0], 0, [[]])
  end

  def hash
    hash_code = 1
    @pages.each do |page|
      hash_code = hash_code ^ page.hash
    end
    @links.each do |link|
      hash_code = hash_code ^ link.hash
    end
    hash_code
  end

  def to_html
    pfd_erb = ERB.new(IO.readlines(PFDTemplateFile).join, 0, "%<>")
    pfd_erb.result(binding)
  end

  def to_s
    pages_str = @pages.map(&:to_s).join("\n\t")
    links_str = @links.map(&:to_s).join("\n\t")
    sprintf("Pages (%d):\n\t%s\nLinks (%d):\n\t%s",
      @pages.length,
      pages_str,
      @links.length,
      links_str)
  end

  private
      def preorder(page, level, test_paths)
        if test_paths.last.length <= level
          # Based on level, still appending to the last test case
          test_paths.last << page.uri
        else
          # Have finished concatenating test case, so start a new one based
          # on the test case we just completed
          new_path = test_paths.last.dup[0...level]
          new_path << page.uri
          test_paths << new_path
        end
        unless page.is_copy
          page.links.each do |link|
            preorder(link.target_page, level + 1, test_paths)
          end
        end
        test_paths
      end  
end
