class Flogiston::Admin::TemplatesController < AdminController
  def index
    @templates = Template.all.sort_by(&:handle)
    @title = 'View all templates'
  end

  def show
    @template_obj = Template.find(params[:id])
    @title = "Viewing template '#{@template_obj.handle}'"
  end

  def new
    @template_obj = Template.new
    @title = 'New template'
  end

  def create
    @template_obj = Template.new(params[:template])
    
    if !preview? and @template_obj.save
      redirect_to(admin_template_path(@template_obj))
    else
      @title = 'New template'
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
    template_obj = Template.find(params[:id])
    template_obj.destroy
    redirect_to admin_templates_path
  end
  
  
  private
  
  def preview?
    !params[:preview].blank?
  end
end
