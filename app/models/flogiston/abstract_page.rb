class Flogiston::AbstractPage < ActiveRecord::Base
  set_table_name 'pages'

  class << self
    def default_replacements
      Hash.new('')
    end

    def expand(text, replacements)
      return '' unless text

      replacements = replacements.stringify_keys

      text.gsub(/(^\s*)?\{\{\s*\w+\s*\}\}/) do |pattern|
        handle = pattern.match(/\w+/)[0]
        snippet = Snippet.find_by_handle(handle)
        contents = snippet ? snippet.full_contents : (replacements.has_key?(handle) ? replacements[handle] : default_replacements[handle])

        whitespace = pattern.match(/^\s*/)[0]
        contents.gsub(/^/, whitespace)
      end
    end
  end

  # Kernel#format is troublesome
  def format
    attributes['format']
  end

  def formatter
    fmt = format || default_format

    case fmt
    when 'raw'
      Formatter::Raw
    when 'markdown'
      Formatter::Markdown
    when 'haml'
      Formatter::Haml
    end
  end

  module Formatter
    module Markdown
      class << self
        def process(text)
          RDiscount.new(text).to_html
        end
      end
    end

    module Raw
      class << self
        def process(text)
          text
        end
      end
    end

    module Haml
      class << self
        def process(text)
          scope = PagesController.helpers
          ::Haml::Engine.new(text).to_html(scope)
        end
      end
    end
  end
end
