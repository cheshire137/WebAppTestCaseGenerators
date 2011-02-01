module ERBGrammar
  class FakeERBOutput
    include SharedSexpMethods
    extend SharedSexpMethods::ClassMethods
    include SharedMethods
    attr_reader :index, :lines_of_code, :content

    def initialize(code, index)
      if code.is_a?(String)
        @lines_of_code = [code]
      elsif code.is_a?(Array)
        @lines_of_code = code
      else
        raise ArgumentError, "Expected String or Array code"
      end
      unless index.is_a?(Fixnum)
        raise ArgumentError, "Expected Fixnum index"
      end
      @content = nil
      @index = index
    end

    def ==(other)
      return false if other.nil?
      other.respond_to?(:lines_of_code) && !other.lines_of_code.nil? &&
        other.lines_of_code == @lines_of_code
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
      @lines_of_code.collect do |code|
        'puts "' + FakeERBOutput.escape_value(code) + '"'
      end.join("\n")
    end

    def to_s(indent_level=0)
      to_s_with_prefix(indent_level, "FakeERBOutput " + @lines_of_code.join("\n"))
    end

    private
      def self.escape_value(value)
        return nil if value.nil?
        value.gsub(/"/, "\\\"")
      end
  end
end
