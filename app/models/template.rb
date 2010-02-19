class Template < AbstractPage
  has_many :pages
  
  validates_uniqueness_of :handle
  
  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end
  
  ### for ActionView Layout fakery
  def path_without_format_and_extension
    "<Template '#{handle}'>"
  end
  
  def render_template(view, local_assigns = {})
    view_contents = view.instance_variable_get('@content_for_layout')
    renderer = ActionView::Base.new
    renderer.controller = view.controller
    renderer.render({ :inline => full_contents(:contents => view_contents) }, local_assigns)
  end
  
  def refresh
    reload unless new_record?
    self
  end
  ###
end
