class Flogiston::Template < Flogiston::AbstractPage
  has_many :pages

  validates_uniqueness_of :handle
  validates_presence_of   :handle

  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end

  def replacements
    contents.scan(/\{\{\s*(\w+)\s*\}\}/).flatten - %w[contents]
  end
end
