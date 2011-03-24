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
