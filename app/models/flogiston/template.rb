class Flogiston::Template < Flogiston::AbstractPage
  validates_uniqueness_of :handle
  
  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end
end
