# scriptlines.rb
# A ScriptLines instance analyses a Ruby script and maintains
# counters for the total number of lines, lines of  
# code, etc.
class ScriptLines

  attr_reader :name
  attr_accessor :bytes, :lines, :lines_of_code, :comment_lines

  LINE_FORMAT = '%8s %8s %8s %8s %s'

  def self.headline
    sprintf LINE_FORMAT, "BYTES", "LINES", "LOC", "COMMENT", "FILE"
  end

  # The 'name' argument is usually a filename
  def initialize(name)
    @name = name
    @bytes = 0
    @lines = 0    # total number of lines
    @lines_of_code = 0
    @comment_lines = 0
  end

  # Iterates over all the lines in io (io might be a file or a
  # string), analyses them and appropriately increases the counter
  # attributes.
  def read(io)
    in_multiline_comment = false
    io.each { |line|
      @lines += 1
      @bytes += line.size
      case line
      when /^=begin(\s|$)/
        in_multiline_comment = true
        @comment_lines += 1
      when /^=end(\s|$)/:
        @comment_lines += 1
        in_multiline_comment = false
      when /^\s*#/
        @comment_lines += 1
      when /^\s*$/
        # empty/whitespace only line
      else
        if in_multiline_comment
          @comment_lines += 1
        else
          @lines_of_code += 1
        end
      end
    }
  end

  # Get a new ScriptLines instance whose counters hold the
  # sum of self and other.
  def +(other)
    sum = self.dup
    sum.bytes += other.bytes
    sum.lines += other.lines
    sum.lines_of_code += other.lines_of_code
    sum.comment_lines += other.comment_lines
    sum
  end

  # Get a formatted string containing all counter numbers and the
  # name of this instance.
  def to_s
    sprintf LINE_FORMAT,
      @bytes, @lines, @lines_of_code, @comment_lines, @name
  end
end