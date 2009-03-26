module PagesHelper
  def format_text(text)
    return '' if text.nil?
    RDiscount.new(text).to_html
  end
  
  def show_invalid_handle(page)
    if page.valid_handle?
      ''
    else
      '<span class="error">!</span>'
    end
  end
end 
