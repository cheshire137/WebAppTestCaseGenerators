module ERBGrammar
  Tab = '  '

  class ERBDocument < Treetop::Runtime::SyntaxNode
    def each
      yield node
      unless x.empty? || !x.respond_to?(:each)
        x.each do |other|
          yield other
        end
      end
    end
    def each_with_index
      i = 0
      each do |node|
        yield node, i
        i += 1
      end
    end
    def inspect
      to_s
    end
    def length
      1 + (x.respond_to?(:length) ? x.length : 0)
    end
    def to_s(indent_level=0)
      str = Tab * indent_level
      str << if x.empty?
        node.to_s(indent_level)
      else
        sprintf("%s\n%s", node.to_s, x.to_s(indent_level))
      end
      str
    end
  end

  class ERBOutputTag < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      code == other.code
    end
    def hash
      code.hash
    end
    def inspect
      sprintf("%s: %s", self.class, ruby_code)
    end
    def ruby_code
      code.content_removing_trims
    end
    def to_s(indent_level=0)
      Tab * indent_level + ruby_code
    end
  end

  class ERBTag < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      code == other.code
    end
    def hash
      code.hash
    end
    def inspect
      sprintf("%s: %s", self.class, ruby_code)
    end
    def ruby_code
      code.text_value_removing_trims.strip
    end
    def to_s(indent_level=0)
      Tab * indent_level + ruby_code
    end
  end

  class HTMLOpenTag < Treetop::Runtime::SyntaxNode
    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end
    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name && attributes_str == other.attributes_str
    end
    def hash
      name.hash ^ attributes_str.hash
    end
    def name
      tag_name.text_value
    end
    def inspect
      sprintf("%s: %s %s", self.class, name, attributes_str)
    end
    def pair_match?(other)
      other.is_a?(HTMLCloseTag) && name == other.name
    end
    def to_s(indent_level=0)
      Tab * indent_level + name + ' ' + attributes_str
    end
  end

  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name
    end
    def hash
      name.hash
    end
    def name
      tag_name.text_value
    end
    def inspect
      sprintf("%s: %s", self.class, name)
    end
    def pair_match?(other)
      other.is_a?(HTMLOpenTag) && name == other.name
    end
    def to_s(indent_level=0)
      sprintf("%s/%s", Tab * indent_level, name)
    end
  end

  class HTMLSelfClosingTag < Treetop::Runtime::SyntaxNode
    def attributes_str
      attrs.empty? ? '' : attrs.to_s
    end
    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name && attributes_str == other.attributes_str
    end
    def hash
      name.hash ^ attributes_str.hash
    end
    def name
      tag_name.text_value
    end
    def inspect
      sprintf("%s: %s %s", self.class, name, attributes_str)
    end
    def to_s(indent_level=0)
      Tab * indent_level + sprintf("%s %s", name, attributes_str)
    end
  end

  class HTMLTagAttributes < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      this_arr = to_a
      other_arr = other.to_a
      return false if this_arr.length != other_arr.length
      this_arr.each_with_index do |el, i|
        return false unless el == other_arr[i]
      end
    end
    def hash
      h = 0
      to_a.each do |el|
        h = h ^ el.hash
      end
      h
    end
    def to_a
      arr = [head]
      unless tail.empty?
        arr += tail.elements.first.to_a
      end
      arr
    end
    def to_h
      hash = {}
      hash[head.name] = head.value
      unless tail.empty?
        hash.merge!(tail.elements.first.to_h)
      end
      hash
    end
    def to_s
      to_a.map(&:to_s).join(', ')
    end
  end

  class HTMLTagAttribute < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name && value == other.value
    end
    def hash
      name.hash ^ value.hash
    end
    def name
      (n.text_value =~ /[-:]/) ? "'#{n.text_value}'" : ":#{n.text_value}"
    end
    def value
      v.text_value
    end
    def inspect
      sprintf("%s: %s => %s", self.class, name, value)
    end
    def to_s(indent_level=0)
      Tab * indent_level + sprintf("%s => %s", name, value)
    end
  end

  class HTMLQuotedValue < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      value == other.value
    end
    def hash
      value.hash
    end
    def inspect
      sprintf("%s: %s", self.class, value)
    end
    def to_s(indent_level=0)
      Tab * indent_level + value
    end
    def value
      val.text_value
    end
    def convert
      extract_erb(val.text_value)
    end
    def parenthesize_if_necessary(s)
      return s if s.strip =~ /^\(.*\)$/ || s =~ /^[A-Z0-9_]*$/i
      "(" + s + ")"
    end
    def extract_erb(s, parenthesize = true)
      if s =~ /^(.*?)<%=(.*?)%>(.*?)$/
        #pre, code, post = $1.html_unescape.escape_single_quotes, $2, $3.html_unescape.escape_single_quotes
        pre, code, post = $1, $2, $3
        out = ""
        out = "'#{pre}' + " unless pre.length == 0
        out += parenthesize_if_necessary(code.strip)
        unless post.length == 0
          post = extract_erb(post, false)
          out += " + #{post}"
        end
        out = parenthesize_if_necessary(out) if parenthesize
        out
      else
        #"'" + s.html_unescape.escape_single_quotes + "'"
        "'" + s + "'"
      end
    end
  end

  class RubyCode < Treetop::Runtime::SyntaxNode
    def eql?(other)
      return false unless other.is_a?(self.class)
      content_removing_trims == other.content_removing_trims
    end
    def hash
      content_removing_trims.hash
    end
    def content_removing_trims
      result.gsub(/\s*\-\s*$/, '')
    end
    def text_value_removing_trims
      text_value.gsub(/\s*\-\s*$/, '')
    end
    def result
      code = text_value.strip
      # matches a word, followed by either a word, a string, or a symbol
      code.gsub(/^(\w+) ([\w:"'].*)$/, '\1(\2)')
    end
    def to_s(indent_level=0)
      Tab * indent_level + result
    end
  end
end
