class ScatterController < ApplicationController
  before_filter :authenticate_user!
  
  
  def new
    @update = ScatterUpdate.new
    # comments (changelog)
    # version number
    authorize! :manage, @update
    
    respond_to do |format|
      format.html # new.html.erb
    end        
  end
  
  def create 
     @update = ScatterUpdate.new(params[:scatter_update])    
     authorize! :manage, @update
     
     # notify users
     if @update.save
       if @update.email_users == '1'            
         # get all users tht downloaded last version for emailing
         lastversion = ScatterDownload.last.version
         prefix = lastversion.split(/\./)[0]
         user_set = User.joins(:scatter_downloads).where("scatter_downloads.email" => 1).where("scatter_downloads.version LIKE ?", "#{prefix}.%")
         emails = user_set.collect{|x| x.email}         
         emails.uniq!
         
         emails << 'robert.rambo@diamond.ac.uk'                        
        
         emails.each do |email|      
           Notifier.send_update_notice(email, @update).deliver                  
         end                            
       end
       
       redirect_to experiments_admin_list_path, :notice => 'Successfully updated Scatter'
#       format.html { redirect_to :controller=> 'experiments', :action => 'admin_list', :notice => 'Scatter Successfully uploaded' }                     
     else
       @update.zipfile.clear
       @update.zipfile.queued_for_write.clear       
       flash[:error] = @update.errors.inspect
       
       render 'new'
     end
  end
  
  
  def request_download
    lastversion = ScatterUpdate.last.version

    @request = ScatterDownload.new(:user_id=>current_user.id, :ip_address => request.remote_ip, :version => lastversion, :email => true)

    respond_to do |format|
      format.html 
    end        
  end
  
   
  def download
    
   @request = ScatterDownload.new(params[:scatter_download])
   
   if @request.save
     # render success page
     
     @all = ScatterDownload.find_all_by_user_id(current_user.id)
       
     sendFile   
     #
     # send me an email
     #
     Notifier.send_me_notice(@request).deliver
     
     return
   else
     flash[:notice] = "Please check your entries."
     render :action => "request_download" and return
   end

  end
  
  def thank_you
    @all = ScatterDownload.find_all_by_user_id(current_user.id)
  end
    
private
  
  def sendFile
    send_file("#{Rails.root}/public/scatter.zip", :filename => 'scatter.zip')
  end
  
end
