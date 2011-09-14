class Flogiston::Snippet < Flogiston::AbstractPage
  validates_uniqueness_of :handle
  validates_presence_of   :handle

  alias_attribute :full_contents, :contents
end
