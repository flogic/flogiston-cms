class Flogiston::Page < Flogiston::AbstractPage
  belongs_to :template

  validates_uniqueness_of :handle

  serialize :values, Hash
  
  def validate
    unless valid_handle?
      errors.add(:handle, "'#{handle}' is not allowed")
    end
  end
  
  def valid_handle?
    self.class.valid_handle?(handle)
  end
  
  class << self
    def valid_handle?(handle)
      handle = "/#{handle}" unless (handle || '')[0,1] == '/'
      recog = ActionController::Routing::Routes.recognize_path(handle, :method => :get)
      !!(recog[:controller] == 'pages' && recog[:path])
    rescue ActionController::RoutingError
      true
    end
  end
  
  def path
    "/#{handle}"
  end
  
  def full_contents
    expanded = formatted
    return expanded unless template

    replacements = values || {}
    replacements.merge!('contents' => expanded)
    template.full_contents(replacements)
  end

  def template_replacements
    return [] unless template
    template.replacements
  end

  def formatted
    return '' unless contents
    processed = formatter.process(contents)
    self.class.expand(processed, {})
  end

  def default_format
    'markdown'
  end
end
