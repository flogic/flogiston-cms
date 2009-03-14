class Admin::PagesController < ApplicationController
  layout 'admin'

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to(admin_page_path(@page))
    else
      render :action => 'new'
    end
  end
end
