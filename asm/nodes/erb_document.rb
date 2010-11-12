module ERBGrammar
  class ERBDocument < Treetop::Runtime::SyntaxNode
    include Enumerable
    def [](index)
      each_with_index do |el, i|
        return el if i == index
      end
      nil
    end
    def each
      yield node
      x.each { |other| yield other } unless x.nil? || !x.respond_to?(:each)
    end
    def inspect
      to_s
    end
    def length
      1 + (x.respond_to?(:length) ? x.length : 0)
    end
    def pair_tags
      mateless = []
      each_with_index do |element, i|
        next unless element.respond_to? :index
        element.index = i
        next unless element.respond_to? :pair_match?
        # Find first matching mate for this element in the array of mateless
        # elements.  First matching mate will be latest added element.
        mate = mateless.find { |el| el.pair_match?(element) }
        if mate.nil?
          # Add mate to beginning of mateless array, so array is sorted by
          # most-recently-found to earliest-found.
          mateless.insert(0, element)
        else
          if mate.respond_to? :close
            mate.close = element
            mateless.delete(mate)
          else
            raise "Mate found out of order: " + mate.to_s + ", " + element.to_s
          end
        end
      end
    end
    def to_s
      map(&:to_s).join("\n")
    end
  end
end
