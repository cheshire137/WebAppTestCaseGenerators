require 'pp'

module SharedSexpMethods
  ITERATION_METHODS = [:each, :each_with_index, :each_cons, :each_entry,
    :each_slice, :each_with_object, :upto, :downto, :times].freeze
  URL_METHODS = [:url_for].freeze
  attr_accessor :sexp

  module ClassMethods
    # If the given Sexp contains a call to the given method name, the Sexp
    # representing the arguments passed in that method call will be returned.
    # Otherwise, nil is returned.
    def get_sexp_for_call_args(sexp, method_name)
      unless method_name.is_a?(Symbol)
        raise ArgumentError, "method_name must be a Symbol"
      end
      return nil if sexp.nil? || method_name.nil? || !sexp.is_a?(Enumerable)
      if :call == sexp.first && (!sexp[1].nil? && method_name == sexp[1][2] || method_name == sexp[2])
        args = sexp[3]
        #puts "Found args:"
        #pp args
        #puts ''
        return nil if args.nil?
        return nil if :arglist != args[0]
        args[1...args.length]
      elsif sexp.is_a?(Sexp)
        get_sexp_for_call_args(sexp[1], method_name)
      else
        nil
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

    def get_sexp_hash_value(sexp, key)
      return nil if sexp.nil? || !sexp.is_a?(Enumerable) || :hash != sexp.first
      if key.nil?
        raise ArgumentError, "Expected non-nil hash key to look up in Sexp"
      end
      key = key.to_s.downcase
      key_value_pairs = sexp[1...sexp.length]
      # Sample:
      # s(:hash,
      #  s(:lit, :action),
      #  s(:str, "try_login"),
      #  s(:lit, :method),
      #  s(:lit, :post))
      # Keys are on even indices, values on the following odd index
      num_pairs = key_value_pairs.length
      key_value_pairs.each_with_index do |key_or_value, i|
        if i.even? && key_or_value[1].to_s.downcase == key && i+1 < num_pairs
          value_sexp = key_value_pairs[i+1]
          if value_sexp.length == 2
            return value_sexp[1]
          else
            return value_sexp
          end
        end
      end
      nil
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

  # Tries to extract a URL from the given Sexp.  Looks for calls to the Rails
  # method url_for(), as well as plain string URLs, as well as
  # controller/action hashes.
  def get_target_page_from_sexp(sexp_args, source=nil)
    if source.nil? || !source.respond_to?(:controller)
      src_controller = nil
    else
      src_controller = source.controller
    end
    sexp_args.each do |sexp|
      controller = self.class.get_sexp_hash_value(sexp, :controller) || src_controller
      action = self.class.get_sexp_hash_value(sexp, :action)
      unless action.nil?
        return RailsURL.new(controller, action, nil) 
      end
      url = self.class.get_sexp_hash_value(sexp, :url)
      unless url.nil?
        return RailsURL.new(nil, nil, url) if url.is_a?(String)
        if url.is_a?(Sexp)
          URL_METHODS.each do |url_method|
            url_args = self.class.get_sexp_for_call_args(url, url_method)
            unless url_args.nil?
              return get_target_page_from_sexp(url_args, source)
            end
          end
        end
      end
    end
    nil
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
      # Call dup() otherwise ERBTag Ruby comments end up with multiple pound
      # signs at the beginning (?!)
      @sexp = parser.parse(ruby_code().dup())
    rescue Racc::ParseError
      @sexp = :invalid_ruby
    rescue SyntaxError
      # Can occur when lines are split on ; and this happens in the
      # middle of a string
      @sexp = :invalid_ruby
    end
    #pp @sexp
    #puts ''
  end

  def selection_true_case?(exp_true_sexp)
    true_case = @sexp[2]
    sexp_contains_sexp?(exp_true_sexp, true_case)
  end

  def selection_false_case?(exp_false_sexp)
    case @sexp[0]
    when :case
      false_case = @sexp[3...@sexp.length]
    else
      false_case = @sexp[3]
    end
    sexp_contains_sexp?(exp_false_sexp, false_case)
  end

  # p -> p1 | p2 (conditionals)
  def selection?
    set_sexp() if @sexp.nil?
    return false if :invalid_ruby == @sexp
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
    # Return here when, for example, there's an if statement within an ERBOutputTag,
    # e.g., <%= (user.id == session[:user][:id]) ? 'you' : user.email %>
    return unless respond_to?(:branch_content=)
    return if :invalid_ruby == @sexp
    # Expect non-ERBTag content to be contained in AtomicSections, so
    # only get ERBTags who might have nested AtomicSections within them,
    # as opposed to HTMLOpenTags and whatnot that would be duplicated
    # within AtomicSections we've already got
    erb_content = (@content || []).select do |child|
      child.set_sexp() if child.sexp.nil?
      child.is_a?(ERBGrammar::ERBTag)
    end
    #puts "\nAll ERB content:"
    #pp erb_content
    case @sexp[0]
    when :case
      split_case_branch(erb_content)
    else
      split_if_else_branch(erb_content)
    end
  end
  
  def split_case_branch(erb_content)
    # Split branches on contents first, in case there are nested case-whens
    erb_content.map(&:split_branch)
    @branch_content ||= []
    return if @close.nil?
    
    atomic_sections = @atomic_sections || []
    # Find all invalid Ruby, and assume it's the pivot points
    pivots = erb_content.select do |child|
      :invalid_ruby == child.sexp
    end.sort { |a, b| a.index <=> b.index }
    return if pivots.empty? || pivots.length < 2
    
    prev_pivot = pivots[0]
    prev_index = prev_pivot.index
    (pivots[1...pivots.length] + [@close]).each do |condition_pivot|
      cond_pivot_index = condition_pivot.index
      is_branch_child = lambda do |child|
        child.index > prev_index && child.index < cond_pivot_index
      end
      branch_erb = erb_content.select(&is_branch_child)
      branch_sections = atomic_sections.select(&is_branch_child)
      branch_content = branch_erb + branch_sections
      if branch_content.empty?
        #puts "No content in branch with condition pivot #{condition_pivot}"
        next
      end
      branch_content.sort! { |a, b| self.class.section_and_node_sort(a, b) }
      copy_atomic_sections(branch_sections, prev_pivot)
      copy_content(branch_erb, prev_pivot)
      delete_children_in_range(branch_content.first.index, branch_content.last.index)
      @branch_content << [condition_pivot]
      
      prev_pivot = condition_pivot
      prev_index = prev_pivot.index
    end
  end
  
  def copy_atomic_sections(sections, parent)
    sections.each do |section|
      parent.add_atomic_section(section)
    end
  end
  
  def copy_content(new_content, parent)
    if parent.content.nil? || parent.content.empty?
      # TODO: do I need to check that all elements in the included
      # content have an index > parent.index and <
      # parent.close?
      parent.content = new_content
    else
      raise "Cannot set content of #{parent}, it is already set"
    end
  end
  
  def split_if_else_branch(erb_content)
    atomic_sections = @atomic_sections || []
    true_erb = erb_content.select do |child|
      selection_true_case?(child.sexp)
    end
    true_sections = atomic_sections.select do |section|
      section.set_sexp() if section.sexp.nil?
      selection_true_case?(section.sexp)
    end
    true_content = true_erb + true_sections
    false_erb = erb_content.select do |child|
      selection_false_case?(child.sexp)
    end
    false_sections = atomic_sections.select do |section|
      selection_false_case?(section.sexp)
    end
    sort_and_set_true_false_content(true_content, false_erb, false_sections)
  end
  
  def sort_and_set_true_false_content(true_content, false_erb, false_sections)
    false_content = false_erb + false_sections
    true_content.sort! { |a, b| self.class.section_and_node_sort(a, b) }
    false_content.sort! { |a, b| self.class.section_and_node_sort(a, b) }
    self.branch_content ||= []
    self.branch_content << true_content
    self.branch_content << false_content
    last_true_index = first_false_index = -1
    unless true_content.nil? || true_content.empty?
      last_true = true_content.last
      last_true_index = last_true.index
      if last_true.respond_to?(:range) && !last_true.range.nil?
        last_true_index = last_true.range.to_a.last
      end
      #puts "Last index in true content: " + last_true_index.to_s
    end
    unless false_content.nil? || false_content.empty?
      first_false_index = false_content.first.index
      #puts "First index in false content: " + first_false_index.to_s
    end
    if 2 == (first_false_index - last_true_index)
      pivot_if_else(last_true_index, false_erb, false_sections)
    end
  end
  
  def pivot_if_else(last_true_index, false_erb, false_sections)
    pivot_index = last_true_index + 1
    condition_pivot = @content.find do |child|
      child.respond_to?(:content=) && pivot_index == child.index
    end
    unless condition_pivot.nil?
      # Move if's close to be the close of this else
      condition_pivot.close = @close

      copy_content(false_erb, condition_pivot)
      copy_atomic_sections(false_sections, condition_pivot)
      
      # Set the if's close to now be this else
      condition_pivot.parent = self
      @close = condition_pivot

      #if @close.respond_to?(:split_branches)
        # In case the else block has its own nested ifs with atomic sections,
        # need to split those out, too
        #@close.split_branches()
      #end
      
      # Wipe out the content that had contained the stuff that is now the
      # content of the conditional's pivot element (e.g., the else), so we
      # don't have repeated content/sections elsewhere.
      start_del_range = pivot_index
      end_del_range = condition_pivot.close.index
      #puts "Deleting children in range #{start_del_range}-#{end_del_range}"
      delete_children_in_range(start_del_range, end_del_range)
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
       sexp_calls_enumerable_method?(@sexp[1])
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
    if sexp_calls_enumerable_method?(@sexp)
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

  private
    def sexp_calls_enumerable_method?(sexp)
      ITERATION_METHODS.each do |method_name|
        return true if self.class.sexp_outer_call?(sexp, method_name)
      end
      false
    end

    def lines_consecutive_in_sexp?(needle, haystack)
      return false if haystack.nil?
      found_each_line_consecutively = true
      index = 0
      prev_index = -1
      num_lines = needle.length
      while index < num_lines && found_each_line_consecutively && !prev_index.nil?
        line = needle[index]
        #puts "Previous matching index: #{prev_index}"
        #puts "Looking for line ##{index} #{line}"
        matching_index = haystack.index { |s| line == s }
        #puts "Found at index ##{matching_index || 'nil'}"
        found_each_line_consecutively = !matching_index.nil? && (-1 == prev_index || matching_index-1 == prev_index)
        #puts "Found each line consecutively: #{found_each_line_consecutively}"
        prev_index = matching_index
        index += 1
      end
      found_each_line_consecutively
    end

    def contained_or_equal?(needle, haystack)
      return false if haystack.nil? || !haystack.is_a?(Sexp)
      if haystack.include?(needle) || haystack == needle
        return true
      end
      haystack.each do |haystack_child|
        if contained_or_equal?(needle, haystack_child)
          return true
        end
      end
      false
    end

    def replace_lvars(sexp_arr, so_far=[])
      return so_far if sexp_arr.nil?
      unless sexp_arr.is_a?(Array)
        raise ArgumentError, "Expected Array, got #{sexp_arr.class.name}"
      end
      first_item = sexp_arr[0]
      if :lvar == first_item
        name = sexp_arr[1]
        replacement = [:call, nil, name, [:arglist]]
        so_far += replacement
      else
        if first_item.is_a?(Array)
          replacement = replace_lvars(first_item, [])
          so_far << replacement unless replacement.nil?
        else
          so_far << first_item
        end
        next_part = sexp_arr[1...sexp_arr.length]
        unless next_part.empty?
          replace_lvars(next_part, so_far)
        end
      end
      so_far
    end

    def sexp_contains_sexp?(needle, haystack)
      return false if haystack.nil? || needle.nil? || :invalid_ruby == needle
      unless needle.is_a?(Sexp)
        raise ArgumentError, "Expected parameter to be of type Sexp, got " + needle.class.name
      end
      unless haystack.is_a?(Sexp)
        raise ArgumentError, "Expected parameter to be of type Sexp, got " + haystack.class.name
      end
      set_sexp() if @sexp.nil?
      if !selection?
        puts "Not a selection"
        return false
      end
      #puts "Looking for"
      #pp needle
      #puts "In"
      #pp haystack
      #puts ''
      return true if contained_or_equal?(needle, haystack)
      #if self.class.sexp_outer_keyword?(haystack, :block)
      #  haystack = haystack[1...haystack.length]
      #end
      if self.class.sexp_outer_keyword?(needle, :block)
        needle = needle[1...needle.length]
      end
      return true if contained_or_equal?(needle, haystack)
      if haystack.to_a.flatten.include?(:lvar)
        # Example:
        # haystack = 
        #s(:call,
        #  nil,
        #  :distance_of_time_in_words_to_now,
        #  s(:arglist, s(:call, s(:lvar, :l), :updated_at, s(:arglist))))
        #
        # needle =
        #s(:call,
        # nil,
        # :distance_of_time_in_words_to_now,
        # s(:arglist,
        #  s(:call, s(:call, nil, :l, s(:arglist)), :updated_at, s(:arglist))))
        new_needle = needle.to_a
        new_haystack = replace_lvars(haystack.to_a)
        if self.class.sexp_outer_keyword?(new_haystack, :block)
          new_haystack = new_haystack[1...new_haystack.length]
        end
        return true if lines_consecutive_in_sexp?(new_needle, new_haystack)
        return true if contained_or_equal?(new_needle, new_haystack)
      else
        return true if lines_consecutive_in_sexp?(needle, haystack)
      end
      false
    end
end
