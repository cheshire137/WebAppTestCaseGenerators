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

class ComponentInteractionModel
  attr_reader :site_root, :start_page, :component_expression, :atomic_sections, :transitions

  def initialize(root_of_site, start_page, comp_expr, sections, trans)
    if root_of_site.nil?
      raise ArgumentError, "Cannot have a nil site root"
    end
    if start_page.nil? || start_page.blank?
      raise ArgumentError, "Cannot have a nil/blank start page"
    end
    if comp_expr.nil?
      raise ArgumentError, "Cannot have a nil component expression"
    end
    if sections.nil? || !sections.is_a?(Array) || sections.empty?
      raise ArgumentError, "Must give at least 1 atomic section in Array (got #{sections.class.name})"
    end
    if trans.nil? || !trans.is_a?(Array)
      raise ArgumentError, "Must give a non-nil Array of transitions (got #{trans.class.name})"
    end
    @site_root = root_of_site
    @start_page = start_page
    @component_expression = comp_expr
    @atomic_sections = sections
    @transitions = trans
  end

  def controller
    rails_uri = RailsURL.from_path(@start_page, @site_root)
    if rails_uri.nil?
      'UNKNOWN'
    else
      rails_uri.controller || 'UNKNOWN'
    end
  end

  def start_url
    file_name = File.basename(@start_page.downcase)
    suffix_start = file_name.index('.')
    if suffix_start.nil?
      method = file_name
    else
      method = file_name[0...suffix_start]
    end
    sprintf("%s/%s/%s", @site_root, controller(), method)
  end

  def to_s
    tab = '  '
    trans_str = @transitions.collect do |trans|
      trans.to_s(tab * 2)
    end.join("\n")
    sprintf("Component Interaction Model\n\tStart page: %s\n\tStart URL: %s\n\tComponent expression: %s\n\tTransitions:\n%s", @start_page, start_url(), @component_expression, trans_str)
  end
end
