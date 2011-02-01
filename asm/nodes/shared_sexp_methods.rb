module SharedSexpMethods
  attr_accessor :sexp

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

  def set_sexp
    #puts "Setting sexp for " + to_s
    return unless @sexp.nil?
    parser = RubyParser.new
    begin
      @sexp = parser.parse(ruby_code)
    rescue Racc::ParseError
      @sexp = :invalid_ruby
    end
    #pp @sexp
  end

  def selection_true_case?(exp_true_sexp)
    return false if :invalid_ruby == exp_true_sexp
    unless exp_true_sexp.is_a?(Sexp)
      raise ArgumentError, "Expected parameter to be of type Sexp, got " + exp_true_sexp.class.name
    end
    set_sexp() if @sexp.nil?
    if !selection?
      puts "Not a selection"
      return false
    end
    true_case = @sexp[2]
    #puts "Looking for "
    #pp exp_true_sexp
    #puts ''
    #puts "In:"
    #pp true_case
    #puts "\n\n"
    if !true_case.nil? && (true_case.include?(exp_true_sexp) || true_case == exp_true_sexp)
      #puts "Found it!"
      return true
    end
    false
  end

  def selection_false_case?(exp_false_sexp)
    return false if :invalid_ruby == exp_false_sexp
    unless exp_false_sexp.is_a?(Sexp)
      raise ArgumentError, "Expected parameter to be of type Sexp, got " + exp_false_sexp.class.name
    end
    set_sexp() if @sexp.nil?
    return false if !selection?
    false_case = @sexp[3]
    if self.class.sexp_outer_keyword?(false_case, :block)
      block_contents = false_case[1...false_case.length]
    else
      block_contents = false_case
    end
    !block_contents.nil? && block_contents.include?(exp_false_sexp)
  end

  # p -> p1 | p2 (conditionals)
  def selection?
    set_sexp() if @sexp.nil?
    if :invalid_ruby == @sexp
      return false
    end
    [:if, :case, :when].each do |keyword|
      return true if self.class.sexp_outer_keyword?(@sexp, keyword)
    end
    false
  end

  # p -> p1 | p2 (conditionals)
  # TODO: expand to handle multiple branches, not just if and else cases
  def selection_with_contents?(exp_true_case_contents, exp_false_case_contents)
    unless exp_true_case_contents.is_a?(Sexp) && exp_false_case_contents.is_a?(Sexp)
      raise ArgumentError, "Expected parameters to be of type Sexp"
    end
    set_sexp() if @sexp.nil?
    return false if :invalid_ruby == @sexp || !selection?
    condition = @sexp[1]
    act_true_case_contents = @sexp[2]
    act_false_case_contents = @sexp[3]
    if self.class.sexp_outer_keyword?(act_false_case_contents, :block)
      block_contents = act_false_case_contents[1...act_false_case_contents.length]
    else
      block_contents = act_false_case_contents
    end
    exp_true_case_contents == act_true_case_contents && exp_false_case_contents == block_contents
  end

  def split_branch
    true_branch = @sexp[2]
    false_branch = @sexp[3]
#    puts "True branch:"
#    pp true_branch
#    puts "\nFalse branch:"
#    pp false_branch
    atomic_sections = @atomic_sections || []
#    puts "Atomic sections:"
#    pp atomic_sections
#    puts "\n"
    # Expect non-ERBTag content to be contained in AtomicSections, so
    # only get ERBTags who might have nested AtomicSections within them,
    # as opposed to HTMLOpenTags and whatnot that would be duplicated
    # within AtomicSections we've already got
    erb_content = @content.select do |child|
      child.set_sexp() if child.sexp.nil?
      child.respond_to?(:sexp) && child.respond_to?(:content) && !child.content.nil?
    end
    true_content = erb_content.select do |child|
      selection_true_case?(child.sexp)
    end + atomic_sections.select do |section|
      section.set_sexp() if section.sexp.nil?
      selection_true_case?(section.sexp)
    end
    false_content = (erb_content - true_content) + (atomic_sections - true_content)
#    puts "True content:"
#    pp true_content
#    puts "\nFalse content:"
#    pp false_content
#    puts "\n------------------------"
    if respond_to?(:true_content=) && respond_to?(:false_content=)
      self.true_content = true_content
      self.false_content = false_content
    else
      raise "Trying to split branch on a " + self.class.name
    end
  end

  # p -> p1* (loops)
  def iteration?
    set_sexp() if @sexp.nil?
    return false if :invalid_ruby == @sexp
    # For cases like the following sexp:
    # s(:iter,
    #  s(:call,
    #   s(:call, s(:ivar, :@game), :get_sorted_scores, s(:arglist, s(:true))),
    #   :each,
    #   s(:arglist)),
    #  s(:lasgn, :score))
    if self.class.sexp_outer_keyword?(@sexp, :iter) &&
       self.class.sexp_outer_call?(@sexp[1], :each)
      #puts "Sexp has a call to :each in iterator--iteration!\n"
      return true
    end
    [:while, :for, :until].each do |keyword|
#      puts "Looking for key word '" + keyword.to_s + "' in "
#      pp @sexp
      if self.class.sexp_outer_keyword?(@sexp, keyword)
#        puts "Found it!\n"
        return true
      end
    end
    if self.class.sexp_outer_call?(@sexp, :each)
#      puts "Sexp has a call to :each--iteration!\n"
      return true 
    end
    false
  end

  # p -> p1{p2} (file inclusion, function calls in p1)
  def aggregation?
    set_sexp() if @sexp.nil?
    return false if :invalid_ruby == @sexp
    return true if self.class.sexp_outer_call?(@sexp, :render)
    false
  end
end
