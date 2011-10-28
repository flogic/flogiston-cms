class Flogiston::Layout < Flogiston::AbstractPage
  validates_uniqueness_of :handle
  validates_presence_of   :handle

  class << self
    def expand(text, replacements, format)
      return '' unless text

      replacements = replacements.stringify_keys

      text.gsub(/(^\s*)?\{\{\s*\w+\s*\}\}/) do |pattern|
        handle = pattern.match(/\w+/)[0]
        snippet = Snippet.find_by_handle(handle)

        if snippet
          whitespace = pattern.match(/^\s*/)[0]
          method = format == 'haml' ? :gsub : :sub
          snippet.full_contents.send(method, /^/, whitespace)
        else
          replacements.has_key?(handle) ? replacements[handle] : ''
        end
      end
    end

    def default
      first(:conditions => { :default => true })
    end
  end

  def make_default!
    Layout.update_all({ :default => false }, "id <> #{self.id}")
    update_attributes!(:default => true)
  end

  def full_contents(replacements = {})
    self.class.expand(contents, replacements, format)
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
