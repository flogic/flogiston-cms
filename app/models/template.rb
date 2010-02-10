class Template < AbstractPage
  has_many :pages
  
  validates_uniqueness_of :handle
  
  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end
  
  
  ### for ActionView Layout fakery
  def path_without_format_and_extension() ''; end
  
  def render_template(view, local_assigns = {})
    ActionView::Base.new.render({ :inline => contents }, local_assigns)
  end
  ###
end
