class TutorialsController < ApplicationController
  def sendform
    send_file("#{Rails.root}/public/bioisis_deposit.pdf",
              :filename      =>  'bioisis_deposit.pdf',
              :type         =>  'application/pdf')
  end
  
  def index
    
    respond_to do |format| #this is REST web-service support telling the server to respond (respond_to) in one of two formats depending on the request
      format.html { render :action => "index"}
    end
  end

  def show
#    @versionhistory = ScatterUpdate.find(:all)
    @versionhistory =  ScatterUpdate.order('created_at DESC')
    
    respond_to do |format|
      format.html { render :action => "show"}
    end
  end
end