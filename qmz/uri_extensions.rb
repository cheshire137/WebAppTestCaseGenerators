require 'uri'

class URI::HTTP
  def get_uniq_parts
    [scheme, host, request_uri]
  end
end
