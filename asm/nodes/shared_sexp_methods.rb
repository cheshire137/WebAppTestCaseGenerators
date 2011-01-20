module SharedSexpMethods
  def sexp_include_call?(sexp, method_name)
    # e.g., sexp =
    # s(:iter,
    #   s(:call, s(:ivar, :@names), :each, s(:arglist)),
    #   s(:lasgn, :blah),
    #   s(:call, nil, :puts, s(:arglist, s(:lvar, :blah))))
    # Another sexp example:
    # s(:call, nil, :render, s(:arglist,
    #   s(:hash, s(:lit, :partial), s(:str, "top_list"),
    #   s(:lit, :collection), s(:ivar, :@wins),
    #   s(:lit, :as), s(:lit, :outcome))))
    unless method_name.is_a?(Symbol)
      raise ArgumentError, "method_name must be a Symbol"
    end
    return false if sexp.nil? || method_name.nil? || !sexp.is_a?(Enumerable)
    if :call == sexp.first && (!sexp[1].nil? && method_name == sexp[1][2] || method_name == sexp[2])
      true
    else
      sexp_include_call?(sexp[1], method_name)
    end
  end
end
