class Flogiston::AbstractPage < ActiveRecord::Base
  set_table_name 'pages'
  
  class << self
    def expand(replacements, text)
      return '' unless text
      
      replacements = replacements.stringify_keys
      
      text.gsub(/\{\{\s*\w+\s*\}\}/) do |pattern|
        handle = pattern.match(/\w+/)[0]
        snippet = Snippet.find_by_handle(handle)
        snippet ? snippet.contents : (replacements.has_key?(handle) ? replacements[handle] : '')
      end
    end
  end
end
