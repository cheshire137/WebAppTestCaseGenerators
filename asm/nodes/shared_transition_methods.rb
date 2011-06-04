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

module ERBGrammar
  module SharedTransitionMethods
    attr_reader :transitions

    def identify_transitions(source_rails_url, root_url)
      if source_rails_url.relative?
        source_rails_url = RailsURL.new(source_rails_url.controller,
                                        source_rails_url.action,
                                        source_rails_url.raw_url,
                                        root_url)
      end
      @transitions = get_local_transitions(source_rails_url)
      children = []
      children += @content || [] if respond_to?(:content)
      children += @atomic_sections || [] if respond_to?(:atomic_sections)
      children.each do |child|
        #puts "Identifying transitions for child: " + child.to_s
        if child.respond_to?(:identify_transitions)
          child.identify_transitions(source_rails_url, root_url)
        end
      end
    end
  end
end
