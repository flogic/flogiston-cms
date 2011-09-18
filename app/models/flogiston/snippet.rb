class Flogiston::Snippet < Flogiston::AbstractPage
  validates_uniqueness_of :handle
  validates_presence_of   :handle

  def full_contents() formatted; end

  def formatted
    formatter.process(contents)
  end

  def default_format
    'raw'
  end
end
