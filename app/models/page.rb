class Page < AbstractPage
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
  
  def full_contents
    contents.gsub(/\{\{\s*\w+\s*\}\}/) do |pattern|
      handle = pattern.match(/\w+/)[0]
      snippet = Snippet.find_by_handle(handle)
      snippet ? snippet.contents : ''
    end
  end
end
