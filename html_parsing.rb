require 'uri'
require 'rubygems'
require 'nokogiri'
require File.join(File.expand_path(File.dirname(__FILE__)), 'link_text.rb')

module SharedHtmlParsing
  module ClassMethods
    TransitionURITypes = [URI::HTTP, URI::FTP]
    SubmitButtonTypes = ['submit', 'image'].freeze

    def get_uri_for_host(str, host_uri)
      unless str.is_a?(String)
        raise ArgumentError, "Expected URI string, got #{src.class.name}"
      end
      unless host_uri.is_a?(URI)
        raise ArgumentError, "Expected host URI, got #{host_uri.class.name}"
      end
      return nil if str.length < 1
      rel_uri = parse_uri_forgivingly(str)
      if rel_uri.nil?
        if str.include?('#')
          # Try to clean up badly formed URIs like http://example.com/#comments#add_comment 
          pound_index = str.index('#')
          str2 = str[0...pound_index]
          rel_uri = parse_uri_forgivingly(str2)
          if rel_uri.nil?
            puts "Unable to parse '#{str}' or '#{str2}' as a URI--skipping"
            return nil
          end
        else
          puts "Unable to parse '#{str}' as a URI--skipping"
          return nil
        end
      end
      absolutize_uri(rel_uri, host_uri)
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
          uri = get_uri_for_host(form['action'], root_uri)
          if include_uri?(uri)
            desc = get_submit_buttons(form.css('input')).join(', ')
            LinkText.new(uri, desc)
          else
            nil
          end
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
        uri = get_uri_for_host(link['href'], root_uri)
        if include_uri?(uri)
          LinkText.new(uri, link.children.to_s)
        else
          nil
        end
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
          if value.nil? || value.length < 1
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

      def include_uri?(uri)
        !uri.nil? && TransitionURITypes.include?(uri.class)
      end
  end
end
