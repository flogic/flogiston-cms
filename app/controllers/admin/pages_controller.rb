class Admin::PagesController < ApplicationController
  layout 'admin'

  def new
    @page = Page.new
  end
end
