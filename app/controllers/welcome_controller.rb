class WelcomeController < ApplicationController
  def index
    #
    #
    #
    @featured_experiment = Experiment.find('72')
    @latest = Experiment.find(:all, :order => "created_at DESC", :limit => 5, :conditions => ['status=1'])
    @news = News.find(:all, :order => "id DESC", :limit => 4) 
    @ids = Experiment.search("")
    #
    @total_SAXS = Experiment.find(:all).size
    #@total_organisms = Organism.find(:all).size
    #@total_genes = Gene.count
    
    respond_to do |format|
      format.html { render :action => "index"}
    end
  end

  def code_search
    @code =  params[:search]  # +params[:code_search][:code_termini]
    @ids = Experiment.search(@code)  
    
    respond_to do |format|
      format.js 
    end    
  end


  def attachment
    send_file("#{Rails.root}/public/saxs_review_102607.pdf",
              :filename      =>  'saxs_review_putnamhammelhuratainer.pdf',
              :type         =>  'application/pdf')
  end

end