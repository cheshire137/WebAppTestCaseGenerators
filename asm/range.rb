class Range
  def <=>(other)
    return -1 if other.nil? || !other.respond_to?(:begin)
    self.begin <=> other.begin
  end
end
