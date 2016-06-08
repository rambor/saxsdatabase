class ExperimentalLinksController < ApplicationController  
  skip_before_filter :verify_authenticity_token  
  def show
    @source_experiment = Experiment.find(params[:id])
    @experiments = Experiment.paginate :per_page => 20, :page => params[:page], :order => "id DESC"
    #
    # Update the page then render the Links List
    #    
    respond_to do |format|
      format.html { render :action => "list" } # new.html.erb
    end
    
  end
  
  def create
    @experiment = Experiment.find(params[:id])
    @experimental_link = @experiment.experimental_links.build(:link_to_id => params[:link_to_id])
    if @experimental_link.save
      flash[:notice] = "<font color=\"red\"><bold>Added link.</bold></font>".html_safe      
      redirect_to(:controller=>"experiments", :action=>"edit", :id=>params[:id])
    else
      flash[:error] = "Could not make link."
      redirect_to(:controller=>"experiments", :action=>"edit", :id=>params[:id])
    end
  end
  
  def destroy
    @experiment = Experiment.find(params[:id])
    #@linked = Experimental_links.find(params[:id])
    if params[:link_id].to_i > 0
      #
      # link
      #
      @linked = @experiment.experimental_links.find_by_link_to_id(params[:link_id])
    elsif params[:inv_link_id].to_i > 0 
      #
      # inverse link
      #
      @linked = @experiment.inverse_experimental_links.find_by_experiment_id(params[:inv_link_id])
    end
    @linked.destroy
    flash[:notice] = "<font color=\"red\"><bold>Removed link!</bold></font>".html_safe
    redirect_to(:controller=>"experiments", :action=>"edit", :id=>params[:id])
  end



end
