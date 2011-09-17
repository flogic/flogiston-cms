module AdminHelper
  register_section 'pages'
  register_section 'snippets'
  register_section 'templates'
  register_section 'layouts'

  def template_options
    options = Template.all.collect { |t|  [t.handle, t.id] }
    options.unshift([]) unless options.blank?
    options
  end

  def layout_format_options
    [
      %w[HAML haml],
      %w[ERB  erb]
    ]
  end
end
