module SharedERBMethods
  module ClassMethods
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

    def sexp_outer_call?(sexp, method_name)
      unless method_name.is_a?(Symbol)
        raise ArgumentError, "method_name must be a Symbol"
      end
      return false if sexp.nil? || method_name.nil? || !sexp.is_a?(Enumerable)
      :call == sexp.first && (!sexp[1].nil? && method_name == sexp[1][2] || method_name == sexp[2])
    end

    def sexp_outer_keyword?(sexp, keyword)
      unless keyword.is_a?(Symbol)
        raise ArgumentError, "keyword must be a Symbol"
      end
      return false if sexp.nil? || keyword.nil? || !sexp.is_a?(Enumerable)
      keyword == sexp.first
    end
  end

  def ==(other)
	super(other) && prop_eql?(other, :code)
  end

  # p -> p1{p2} (file inclusion, function calls in p1)
  def aggregation?
    s = sexp
    return false if s.nil?
    return true if self.class.sexp_outer_call?(s, :render)
    false
  end

  def hash
	prop_hash(:code)
  end

  # p -> p1* (loops)
  def iteration?
    s = sexp
    return false if s.nil?
    [:while, :for, :until].each do |keyword|
      return true if self.class.sexp_outer_keyword?(s, keyword)
    end
    return true if self.class.sexp_outer_call?(s, :each)
    false
  end

  def ruby_code
	code.content_removing_trims
  end

  # p -> p1 | p2 (conditionals)
  def selection?
    s = sexp
    return false if s.nil?
    [:if, :case, :when].each do |keyword|
      return true if self.class.sexp_outer_keyword?(s, keyword)
    end
    false
  end

  # p -> p1 | p2 (conditionals)
  # TODO: expand to handle multiple branches, not just if and else cases
  def selection_with_contents?(exp_true_case_contents, exp_false_case_contents)
    unless exp_true_case_contents.is_a?(Sexp) && exp_false_case_contents.is_a?(Sexp)
      raise ArgumentError, "Expected parameters to be of type Sexp"
    end
    s = sexp
    return false if s.nil? || !selection?
    condition = sexp[1]
    act_true_case_contents = sexp[2]
    act_false_case_contents = sexp[3]
    if self.class.sexp_outer_keyword?(act_false_case_contents, :block)
      block_contents = act_false_case_contents[1...act_false_case_contents.length]
    else
      block_contents = act_false_case_contents
    end
    exp_true_case_contents == act_true_case_contents && exp_false_case_contents == block_contents
  end

  def selection_true_case?(exp_true_sexp)
    outer_sexp = sexp
    return false if s.nil? || !selection?
    true_case = sexp[2]
    !true_case.nil? && true_case.include?(exp_true_sexp)
  end

  def selection_false_case?(exp_false_sexp)
    outer_sexp = sexp
    return false if s.nil? || !selection?
    false_case = sexp[3]
    if self.class.sexp_outer_keyword?(false_case, :block)
      block_contents = false_case[1...false_case.length]
    else
      block_contents = false_case
    end
    !block_contents.nil? && block_contents.include?(exp_false_sexp)
  end
end
