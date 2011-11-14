class Flogiston::Template < Flogiston::AbstractPage
  has_many :pages

  validates_uniqueness_of :handle
  validates_presence_of   :handle

  class << self
    def expand(text, replacements)
      return '' unless text

      replacements = replacements.stringify_keys

      text.gsub(/\{\{\s*\w+\s*\}\}/) do |pattern|
        handle = pattern.match(/\w+/)[0]
        if handle == 'contents'
          if replacements.has_key?(handle)
            replacements[handle]
          else
            '{{ contents }}'
          end
        else
        snippet = Snippet.find_by_handle(handle)
        snippet ? snippet.full_contents : (replacements.has_key?(handle) ? replacements[handle] : '')
        end
      end
    end
  end

  def full_contents(replacements = {})
    replacement_contents = replacements.delete('contents')
    processed = formatted(replacements)
    self.class.expand(processed, 'contents' => replacement_contents)
  end

  def formatted(replacements = {})
    return '' unless contents
    expanded = self.class.expand(contents, replacements)
    formatter.process(expanded)
  end

  def replacements
    return [] unless contents
    contents.scan(/\{\{\s*(\w+)\s*\}\}/).flatten.uniq - %w[contents]
  end

  def default_format
    'raw'
  end
end
