class Snippet < AbstractPage
  validates_uniqueness_of :handle
  
  alias_attribute :full_contents, :contents
end
