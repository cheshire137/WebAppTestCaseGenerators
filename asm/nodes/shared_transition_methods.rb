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
