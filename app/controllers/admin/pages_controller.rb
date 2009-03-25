class Admin::PagesController < ApplicationController
  layout 'admin'

  def index
    @pages = Page.all.sort_by(&:handle)
    @title = 'View all pages'
  end

  def show
    redirect_to(admin_pages_path)
  end

  def new
    @page = Page.new
    @title = 'New Page'
  end

  def create
    @page = Page.new(params[:page])
    
    if !preview? and @page.save
      redirect_to(admin_page_path(@page))
    else
      @title = 'New Page'
      render :action => 'new'
    end
  end

  def edit
    @page = Page.find(params[:id])
    @title = "Editing page '#{@page.title}'"
  end

  def update
    @page = Page.find(params[:id])
    @page.attributes = params[:page]
    
    if !preview? and @page.save
      redirect_to(admin_page_path(@page))
    else
      @title = "Editing page '#{@page.title}'"
      render :action => 'edit'
    end
  end

  def destroy
    page = Page.find(params[:id])
    page.destroy
    redirect_to admin_pages_path
  end
  
  
  private
  
  def preview?
    !params[:preview].blank?
  end
end
