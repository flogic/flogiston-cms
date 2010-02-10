class AbstractPage < ActiveRecord::Base
  set_table_name 'pages'
  
  class << self
    def expand(text)
      return '' unless text      
      text.gsub(/\{\{\s*\w+\s*\}\}/) do |pattern|
        handle = pattern.match(/\w+/)[0]
        snippet = Snippet.find_by_handle(handle)
        snippet ? snippet.contents : ''
      end
    end
  end
end
