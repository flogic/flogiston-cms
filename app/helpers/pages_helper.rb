module PagesHelper
  def format_text(text)
    return '' if text.nil?
    RDiscount.new(text).to_html
  end
end 
