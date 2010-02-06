class Admin::SnippetsController < AdminController
  helper 'pages'

  def index
    @snippets = Snippet.all.sort_by(&:handle)
    @title = 'View all snippets'
  end

  def show
    redirect_to(admin_snippets_path)
  end

  def new
    @snippet = Snippet.new
    @title = 'New Snippet'
  end

  def create
    @snippet = Snippet.new(params[:snippet])
    
    if !preview? and @snippet.save
      redirect_to(admin_snippet_path(@snippet))
    else
      @title = 'New Snippet'
      render :action => 'new'
    end
  end

  def edit
    @snippet = Snippet.find(params[:id])
    @title = "Editing snippet '#{@snippet.title}'"
  end

  def update
    @snippet = Snippet.find(params[:id])
    @snippet.attributes = params[:snippet]
    
    if !preview? and @snippet.save
      redirect_to(admin_snippet_path(@snippet))
    else
      @title = "Editing snippet '#{@snippet.title}'"
      render :action => 'edit'
    end
  end

  def destroy
    snippet = Snippet.find(params[:id])
    snippet.destroy
    redirect_to admin_snippets_path
  end
  
  
  private
  
  def preview?
    !params[:preview].blank?
  end
end
