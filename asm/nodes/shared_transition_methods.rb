module ERBGrammar
  module SharedTransitionMethods
    attr_reader :transitions

    def identify_transitions(source)
#      puts "Getting local transitions for type #{self.class.name}"
      @transitions = get_local_transitions(source)
      children = if respond_to?(:get_sections_and_nodes)
                   get_sections_and_nodes()
                 elsif respond_to?(:content)
                   @content 
                 else
                   nil
                 end || []
      children.each do |child|
#        puts "Identifying transitions for child of type #{child.class.name}"
        if child.respond_to?(:identify_transitions)
          child.identify_transitions(source)
        end
      end
    end
  end
end
