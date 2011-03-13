require 'uri'

class RailsURL
  attr_reader :action, :controller, :raw_url, :site_root

  def initialize(ctrlr, act, raw, root='')
    if (ctrlr.nil? || ctrlr.blank?) && (act.nil? || act.blank?) && (raw.nil? || raw.blank?)
      raise ArgumentError, "Must provide at least one non-null part of URL"
    end
    @controller = (ctrlr || '').strip.downcase
    @action = (act || '').strip.downcase
    @raw_url = (raw || '').strip.downcase
    @site_root = root.strip.downcase
  end

  def RailsURL.from_path(path, site_root='')
	controller_prefix = File.join('app', 'views')
	prefix_start = path.index(controller_prefix)
	return nil if prefix_start.nil?
	controller_index = prefix_start + controller_prefix.length
	with_ext = path[controller_index...path.length]
	ext_start = with_ext.index('.') || with_ext.length
	without_ext = with_ext[0...ext_start]
	controller = File.dirname(without_ext).gsub(/^\//, '')
	action = File.basename(without_ext)
	RailsURL.new(controller, action, nil, site_root)
  end

  def RailsURL.from_uri(uri)
	if uri.nil? || !uri.is_a?(URI)
	  raise ArgumentError, "Expected non-nil URI, got #{uri.class.name}"
	end
	RailsURL.new(nil, nil, uri.to_s)
  end

  def url
    if @raw_url.blank?
      sprintf("%s/%s/%s", @site_root, @controller, @action)
    else
      # TODO: prefix with @site_root if necessary (relative URL)
      @raw_url
    end
  end

  def to_s
    #sprintf("%sRailsURL\n\t%sController: %s\n\t%sAction: %s\n\t%sRaw URL: %s",
    #        prefix, prefix, @controller, prefix, @action, prefix, @raw_url)
    url()
  end
end
