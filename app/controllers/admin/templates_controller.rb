class Admin::TemplatesController < AdminController
  def index
    @templates = Template.all.sort_by(&:handle)
    @title = 'View all templates'
  end

  def show
    @template = Template.find(params[:id])
    @title = "Viewing template '#{@template.handle}'"
  end

  def new
    @template = Template.new
    @title = 'New Template'
  end

  def create
    @template = Template.new(params[:template])
    
    if !preview? and @template.save
      redirect_to(admin_template_path(@template))
    else
      @title = 'New Template'
      render :action => 'new'
    end
  end

  def edit
    @template = Template.find(params[:id])
    @title = "Editing template '#{@template.handle}'"
  end

  def update
    @template = Template.find(params[:id])
    @template.attributes = params[:template]
    
    if !preview? and @template.save
      redirect_to(admin_template_path(@template))
    else
      @title = "Editing template '#{@template.handle}'"
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
