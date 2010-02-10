class Page < AbstractPage
  belongs_to :template
  validates_uniqueness_of :handle
  
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
      recog = ActionController::Routing::Routes.recognize_path(handle)
      !!(recog[:controller] == 'pages' && recog[:path])
    rescue ActionController::RoutingError
      true
    end
  end
  
  def path
    "/#{handle}"
  end
  
  def full_contents(replacements = {})
    self.class.expand(replacements, contents)
  end
end
