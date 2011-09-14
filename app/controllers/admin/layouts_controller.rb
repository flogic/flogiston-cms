class Admin::LayoutsController < AdminController
  def index
    @template_objs = Template.all.sort_by(&:handle)
    @title = 'View all templates'
  end

  def show
    @template_obj = Template.find(params[:id])
    @title = "Viewing template '#{@template_obj.handle}'"
  end

  def new
    @template_obj = Template.new
    @title = 'New Template'
  end

  def create
    @template_obj = Template.new(params[:template])
    
    if !preview? and @template_obj.save
      redirect_to(admin_template_path(@template_obj))
    else
      @title = 'New Template'
      render :action => 'new'
    end
  end

  def edit
    @template_obj = Template.find(params[:id])
    @title = "Editing template '#{@template_obj.handle}'"
  end

  def update
    @template_obj = Template.find(params[:id])
    @template_obj.attributes = params[:template]
    
    if !preview? and @template_obj.save
      redirect_to(admin_template_path(@template_obj))
    else
      @title = "Editing template '#{@template_obj.handle}'"
      render :action => 'edit'
    end
  end

  def destroy
    template = Template.find(params[:id])
    template.destroy
    redirect_to admin_templates_path
  end
  
  
  private
  
  def preview?
    !params[:preview].blank?
  end
end
