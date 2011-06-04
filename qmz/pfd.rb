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

require 'erb'
require 'page.rb'
require 'link.rb'

class PFD
  PFDTemplateFile = 'ptt_template.html.erb'.freeze
  attr_reader :pages, :links, :root_uri

  def initialize(pages, links, root_uri)
    unless pages.respond_to? :each
      raise ArgumentError, "Given pages arg must be enumerable"
    end
    unless links.respond_to? :each
      raise ArgumentError, "Given links arg must be enumerable"
    end
    unless root_uri.is_a? URI
      raise ArgumentError, "Given root_uri must be of type URI"
    end
    @root_uri = root_uri
    @pages = pages
    @links = links
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
    preorder(@pages[0], 0, [[]], "Start page")
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

  def PFD.to_html(site_uri, test_cases)
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
      def preorder(page, level, test_paths, desc_how_got_to_page)
        if test_paths.last.length <= level
          # Based on level, still appending to the last test case
          #test_paths.last << page.uri
          test_paths.last << LinkText.new(page.uri, desc_how_got_to_page)
        else
          # Have finished concatenating test case, so start a new one based
          # on the test case we just completed
          new_path = test_paths.last.dup[0...level]
          #new_path << page.uri
          new_path << LinkText.new(page.uri, desc_how_got_to_page)
          test_paths << new_path
        end
        unless page.is_copy
          page.links.each do |link|
            preorder(link.target_page, level + 1, test_paths, link.description)
          end
        end
        test_paths
      end  
end
