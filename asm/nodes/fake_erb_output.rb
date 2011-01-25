module ERBGrammar
  class FakeERBOutput
    include SharedSexpParsing
    include SharedMethods
    attr_reader :node, :index

    def initialize(node)
      if node.nil?
        raise ArgumentException, "Given node cannot be nil"
      end
      @node = node
      @index = @node.index
    end

    def ==(other)
      return false if other.nil?
      other.respond_to?(:node) && !other.node.nil? &&
        other.node.text_value == @node.text_value
    end

    def inspect
      to_s
    end

    # Need a way of encapsulating non-ERB content in Ruby tags so it can be
    # recognized by the parser relative to the rest of the ERB code.  Wrap
    # HTML tags, etc. in a Ruby string and 'puts' it, so it can be seen,
    # for example, that this particular HTML was within the 'else' portion
    # of an if/else block.
    def ruby_code
      'puts "' + FakeERBOutput.escape_value(@node.text_value) + '"'
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level, "FakeERBOutput " + @node.text_value)
    end

    private
      def self.escape_value(value)
        return nil if value.nil?
        value.gsub(/"/, "\\\"")
      end
  end
end
