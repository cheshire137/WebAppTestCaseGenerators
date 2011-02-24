module ERBGrammar
  module SharedTransitionMethods
    attr_reader :transitions

    def identify_transitions(source)
      #puts "Getting local transitions for: " + to_s().split("\n").first
      @transitions = get_local_transitions(source)
      children = []
      children += @content || [] if respond_to?(:content)
      children += @atomic_sections || [] if respond_to?(:atomic_sections)
      children.each do |child|
        #puts "Identifying transitions for child: " + child.to_s
        if child.respond_to?(:identify_transitions)
          child.identify_transitions(source)
        end
      end
    end
  end
end
