class Admin::PagesController < ApplicationController
  layout 'admin'

  def index
    @pages = Page.all
  end

  def show
    @page = Page.find(params[:id])
  end

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

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to(admin_page_path(@page))
    else
      render :action => 'edit'
    end
  end

  def destroy
    page = Page.find(params[:id])
    page.destroy
    redirect_to admin_pages_path
  end
end
