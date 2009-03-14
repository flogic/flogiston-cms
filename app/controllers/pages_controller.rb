class PagesController < ApplicationController
  def show
    if params[:id]
      @page = Page.find(params[:id])
    elsif params[:path] 
      @page = Page.find_by_handle!(params[:path].first)
    else
      raise ActiveRecord::RecordNotFound
    end
    @title = @page.title
  end
end
