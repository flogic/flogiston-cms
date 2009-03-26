class Page < ActiveRecord::Base
  validates_uniqueness_of :handle
  
  def validate
    unless self.class.valid_handle?(handle)
      errors.add(:handle, "'#{handle}' is not allowed")
    end
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
end
