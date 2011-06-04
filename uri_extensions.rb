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

require 'uri'

class URI::FTP
  # E.g. ["ftp", "blah", "test/", "query=yes"] for URI ftp://blah/test/?query=yes
  def get_uniq_parts
    [scheme, host, path, query]
  end
end

class URI::HTTP
  # Use scheme (e.g. http), host (e.g. google.com), and request_uri,
  # which includes parameters such as ?query=whee but not #comments
  def get_uniq_parts
    [scheme, host, request_uri.gsub(/\/\//, '/')]
  end
end
