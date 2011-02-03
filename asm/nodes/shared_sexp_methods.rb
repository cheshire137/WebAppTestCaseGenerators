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
    erb_content = (@content || []).select do |child|
      child.set_sexp() if child.sexp.nil?
      child.respond_to?(:sexp) && child.respond_to?(:content) && !child.content.nil?
    end
    true_erb = erb_content.select do |child|
      selection_true_case?(child.sexp)
    end
    true_sections = atomic_sections.select do |section|
      section.set_sexp() if section.sexp.nil?
      selection_true_case?(section.sexp)
    end
    true_content = true_erb + true_sections
    false_erb = erb_content - true_erb
    false_sections = atomic_sections - true_sections
    false_content = false_erb + false_sections
#    puts "True content:"
#    pp true_content
#    puts "\nFalse content:"
#    pp false_content
#    puts "\n------------------------"
    if respond_to?(:true_content=) && respond_to?(:false_content=)
      self.true_content = true_content
      self.false_content = false_content
      last_true_index = first_false_index = -1
      index_sort = lambda do |a, b|
        a.index <=> b.index
      end
      unless true_content.nil? || true_content.empty?
        last_true = true_content.sort(&index_sort).last
        last_true_index = last_true.index
        if last_true.respond_to?(:range) && !last_true.range.nil?
          last_true_index = last_true.range.to_a.last
        end
        #puts "Last index in true content: " + last_true_index.to_s
      end
      unless false_content.nil? || false_content.empty?
        first_false_index = false_content.sort(&index_sort).first.index
        #puts "First index in false content: " + first_false_index.to_s
      end
      puts ''
      if 2 == (first_false_index - last_true_index)
        pivot_index = last_true_index + 1
        condition_pivot = @content.find do |child|
          child.respond_to?(:content=) && pivot_index == child.index
        end
        unless condition_pivot.nil?
          # Move if's close to be the close of this else
          condition_pivot.close = @close

          if condition_pivot.content.nil? || condition_pivot.content.empty?
            included_content = false_erb

            included_content.each do |child|
              if child.respond_to?(:parent=)
                child.parent = condition_pivot
              end
            end

            # TODO: do I need to check that all elements in the included
            # content have an index > condition_pivot.index and <
            # condition_pivot.close?
            condition_pivot.content = included_content
          else
            raise "Cannot set content of #{condition_pivot}, it is already set"
          end

          if condition_pivot.atomic_sections.nil? || condition_pivot.atomic_sections.empty?
            false_sections.each do |section|
              condition_pivot.add_atomic_section(section)
            end
          else
            raise "Cannot set atomic sections of #{condition_pivot}, they are already set"
          end

          # Wipe out the content that had contained the stuff that is now the
          # content of the conditional's pivot element (e.g., the else), so we
          # don't have repeated content/sections elsewhere.
          delete_children_in_range(pivot_index, condition_pivot.close.index)

          # Set the if's close to now be this else
          condition_pivot.parent = self
          @close = condition_pivot
        end
      end
    else
      # End up here when, for example, there's an if statement within an ERBOutputTag,
      # e.g., <%= (user.id == session[:user][:id]) ? 'you' : user.email %>
    end
  end


  # p -> p1* (loops)
  def iteration?
    set_sexp() if @sexp.nil?
    if :invalid_ruby == @sexp
#      puts "Invalid ruby for:\n" + to_s
      return false
    end
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
    # TODO: go out and fetch the component expression for the thing
    # being rendered, if possible?
    return true if self.class.sexp_outer_call?(@sexp, :render)
    false
  end
end