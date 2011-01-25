module SharedSexpParsing
  attr_reader :parsed_sexp

  def sexp
    return @parsed_sexp unless @parsed_sexp.nil?
    parser = RubyParser.new
    begin
      @parsed_sexp = parser.parse(ruby_code)
    rescue Racc::ParseError
      @parsed_sexp = :invalid_ruby
    end
    @parsed_sexp
  end
end
