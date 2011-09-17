class Flogiston::Layout < Flogiston::AbstractPage
  validates_uniqueness_of :handle
  validates_presence_of   :handle

  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end
  
  ### for ActionView Layout fakery
  def path_without_format_and_extension
    "<Layout '#{handle}'>"
  end
  
  def render_template(view, local_assigns = {})
    renderer = ActionView::Template.new('')
    renderer.instance_eval <<-eval_string
      def source
        #{full_contents.inspect}
      end

      def recompile?
        true
      end

      def extension
        #{format.inspect}
      end
    eval_string
    renderer.render_template(view, local_assigns)
  end
  
  def refresh
    reload unless new_record?
    self
  end
  ###
  
  ### for ActionView Template (view) fakery
  def exempt_from_layout?
    false
  end
  ###
end
