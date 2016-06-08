class NewsController < ApplicationController
  
  
  def index
    @news = News.paginate :per_page => 5, :page => params[:page], :order => "id DESC" 

    respond_to do |format|
      format.html
    end
  end
  
  def reviews
    @news = News.paginate :per_page => 5, :page => params[:page], :conditions => "category LIKE \'%review%\'", :order => 'created_at DESC'         
    respond_to do |format|
      format.html
    end         
  end
  
  def articles
    @news = News.paginate :per_page => 5, :page => params[:page], :conditions => "category LIKE \'%article%\'", :order => 'created_at DESC'         
    respond_to do |format|
      format.html
    end         
  end  

  def updates
    @news = News.paginate :per_page => 5, :page => params[:page], :conditions => "category LIKE \'%updates%\'", :order => 'created_at DESC'         
    respond_to do |format|
      format.html
    end         
  end
  
  def general_info
    @news = News.paginate :per_page => 5, :page => params[:page], :conditions => "category LIKE \'%general%\'", :order => 'created_at DESC'         
    respond_to do |format|
      format.html
    end         
  end
  
  def new
    #
    # must be logged in
    #
    @news = News.new
    authorize! :manage, @news
    @news.user_id = current_user.id
    #
    respond_to do |format|
      format.html
    end    
  end
  
  def create
    @news = News.new(params[:news])
    @news.user_id = current_user.id    
    authorize! :manage, @news
    
    if @news.save
      flash[:notice] = 'Entry was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end      
  end
  
  def update
    @news = News.find(params[:id])
    @news.user_id = current_user.id     
    authorize! :manage, @news    
    if @news.update_attributes(params[:news])
      flash[:notice] = 'Entry was successfully updated.'    
      redirect_to :action => 'index'
    end
    flash[:notice] = 'Entry was successfully updated.'
  end
    
  def edit
    @news = News.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    news = News.find(params[:id])
    if news.destroy
      redirect_to :action => 'index'
    else
      flash[:notice] = 'Entry was not destroyed.'      
    end
  end
end
