class Flogiston::Admin::LayoutsController < AdminController
  def index
    @layouts = Layout.all.sort_by(&:handle)
    @title = 'View all layouts'
  end

  def show
    @layout = Layout.find(params[:id])
    @title = "Viewing layout '#{@layout.handle}'"
  end

  def new
    @layout = Layout.new
    @title = 'New layout'
  end

  def create
    @layout = Layout.new(params[:layout])
    
    if !preview? and @layout.save
      redirect_to(admin_layout_path(@layout))
    else
      @title = 'New layout'
      render :action => 'new'
    end
  end

  def edit
    @layout = Layout.find(params[:id])
    @title = "Editing layout '#{@layout.handle}'"
  end

  def update
    @layout = Layout.find(params[:id])
    @layout.attributes = params[:layout]
    
    if !preview? and @layout.save
      redirect_to(admin_layout_path(@layout))
    else
      @title = "Editing layout '#{@layout.handle}'"
      render :action => 'edit'
    end
  end

  def destroy
    layout = Layout.find(params[:id])
    layout.destroy
    redirect_to admin_layouts_path
  end

  def default
    layout = Layout.find(params[:id])
    layout.make_default!
    redirect_to admin_layouts_path
  end

  private
  
  def preview?
    !params[:preview].blank?
  end
end
