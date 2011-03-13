require 'uri'
require 'rubygems'
require 'nokogiri'

module SharedHtmlParsing
  module ClassMethods
    def extract_uris_on_host(uris, target_host)
      uris.compact.select do |uri|
        target_host == uri.host
      end.uniq
    end

    def get_uri_for_host(str, host_uri)
      if str.nil?
        raise ArgumentError, "Cannot work with nil URI string"
      end
      unless str.is_a? String
        raise ArgumentError,
          "Given URI string must be a String, was given a(n) " + str.class.name
      end
      unless host_uri.is_a? URI
        raise ArgumentError, "Given host must be a URI, was given a(n) " +
          host_uri.class.name
      end
      uri = parse_uri_forgivingly(str)
      if !uri.nil? && uri.is_a?(URI::Generic) && uri.host.nil? && !host_uri.is_a?(URI::Generic)
        uri = parse_uri_forgivingly(
          sprintf("%s://%s%s", host_uri.scheme, host_uri.host, uri.to_s)
        )
      end
      uri
    end

    def parse_uri_forgivingly(str)
      begin
        URI.parse(str)
      rescue URI::InvalidURIError
        nil
      end
    end

	def get_form_uris(root_uri, html)
	  if root_uri.nil? || !root_uri.is_a?(URI)
		raise ArgumentError, "Expected URI, got #{root_uri.class.name}"
	  end
      target_host = root_uri.host
      doc = Nokogiri::HTML(html)
	  extract_uris_on_host(
        doc.css('form').select do |form|
          if form['action'].nil?
            false
          else
            input_types = form.css('input').collect do |input|
              input['type']
            end.map(&:downcase)
            input_types.include?('submit') || input_types.include?('image')
          end
        end.collect do |form|
          get_uri_for_host(form['action'], root_uri)
        end,
        target_host
      ).uniq
	end

    def get_link_uris(root_uri, html)
	  if root_uri.nil? || !root_uri.is_a?(URI)
		raise ArgumentError, "Expected URI, got #{root_uri.class.name}"
	  end
      target_host = root_uri.host
      doc = Nokogiri::HTML(html)
	  all_uris = doc.css('a').select do |link|
		!link['href'].nil?
	  end.collect do |link|
		get_uri_for_host(link['href'], root_uri)
	  end
      extract_uris_on_host(all_uris, target_host).uniq
    end
  end
end
