require 'uri'
require 'rubygems'
require 'nokogiri'
require File.join(File.expand_path(File.dirname(__FILE__)), 'link_text.rb')

module SharedHtmlParsing
  module ClassMethods
    SubmitButtonTypes = ['submit', 'image'].freeze

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
      absolutize_uri(parse_uri_forgivingly(str), host_uri)
    end

    def parse_uri_forgivingly(str)
      begin
        URI.parse(str)
      rescue URI::InvalidURIError
        nil
      end
    end

	def get_form_uris(root_uri, doc)
	  get_form_uris_with_text(root_uri, doc).map(&:uri)
	end

    def get_form_uris_with_text(root_uri, doc)
	  if root_uri.nil? || !root_uri.is_a?(URI)
		raise ArgumentError, "Expected URI, got #{root_uri.class.name}"
	  end
      target_host = root_uri.host
	  extract_uris_on_host(
        doc.css('form').select do |form|
          if form['action'].nil?
            false
          else
            !get_submit_buttons(form.css('input')).empty?
          end
        end.collect do |form|
          LinkText.new(get_uri_for_host(form['action'], root_uri),
                       get_submit_buttons(form.css('input')).join(', '))
        end,
        target_host
      ).uniq
    end

    def get_link_uris(root_uri, doc)
      get_link_uris_with_text(root_uri, doc).map(&:uri)
    end

    def get_link_uris_with_text(root_uri, doc)
      if root_uri.nil? || !root_uri.is_a?(URI)
		raise ArgumentError, "Expected URI, got #{root_uri.class.name}"
	  end
      target_host = root_uri.host
	  all_uris = doc.css('a').select do |link|
		!link['href'].nil?
	  end.collect do |link|
        LinkText.new(get_uri_for_host(link['href'], root_uri), link.children.to_s)
	  end
      extract_uris_on_host(all_uris, target_host).uniq
    end

    private
      def absolutize_uri(relative_uri, root_uri)
        if relative_uri.nil? || !relative_uri.is_a?(URI::Generic)
          raise ArgumentError, "Expected a relative URI, got #{relative_uri.class.name}"
        end
        if root_uri.nil? || !root_uri.is_a?(URI::Generic)
          raise ArgumentError, "Expected a root URI, got #{root_uri.class.name}"
        end
        if root_uri.relative?
          raise ArgumentError, "Expected absolute root URI, got a relative root URI #{root_uri}"
        end
        return relative_uri unless relative_uri.relative?
        rel_uri_str = relative_uri.to_s || ''
        slash = rel_uri_str.start_with?('/') ? '' : '/'
        abs_path = sprintf("%s://%s%s%s", root_uri.scheme, root_uri.host, slash, relative_uri.to_s)
        parse_uri_forgivingly(abs_path)
      end

      def get_submit_buttons(inputs)
        (inputs || []).select do |input|
          !input.nil? && SubmitButtonTypes.include?(input['type'].downcase)
        end.collect do |input|
          value = input['value']
          if value.nil? || value.blank?
            src = input['src']
            id = input['id']
            src_id = sprintf("source %s, ID %s", src, id)
            sprintf("%s button - %s", input['type'], src_id)
          else
            value
          end
        end
      end

      def extract_uris_on_host(link_texts, target_host)
        link_texts.compact.select do |link_text|
          uri = link_text.uri
          target_host == uri.host || uri.relative?
        end.uniq
      end
  end
end
