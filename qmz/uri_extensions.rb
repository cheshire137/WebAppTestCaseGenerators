require 'uri'

class URI::HTTP
  # Use scheme (e.g. http), host (e.g. google.com), and request_uri,
  # which includes parameters such as ?query=whee but not #comments
  def get_uniq_parts
    [scheme, host, request_uri]
  end
end
