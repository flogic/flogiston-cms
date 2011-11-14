class Flogiston::Template < Flogiston::AbstractPage
  has_many :pages

  validates_uniqueness_of :handle
  validates_presence_of   :handle

  def full_contents(replacements = {})
    processed = formatted(replacements)
    self.class.expand(processed, replacements)
  end

  def formatted(replacements = {})
    return '' unless contents
    expanded = self.class.expand(contents, replacements)
    formatter.process(expanded)
  end

  def replacements
    return [] unless contents
    contents.scan(/\{\{\s*(\w+)\s*\}\}/).flatten.uniq - %w[contents]
  end

  def default_format
    'raw'
  end
end
