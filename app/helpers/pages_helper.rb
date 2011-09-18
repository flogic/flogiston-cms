module PagesHelper
  def show_invalid_handle(page)
    if page.valid_handle?
      ''
    else
      '<span class="error">!</span>'
    end
  end
end 
