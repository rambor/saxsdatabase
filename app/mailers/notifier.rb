class Notifier < ActionMailer::Base
  helper :application
  default :from => "no-reply@bioisis.net"
  
  def registration(recipient)
    @submission = recipient
    file = "#{Rails.root}/public/bioisis_deposit.pdf"
    
    @link = "http://www.bioisis.net/deposition/#{@submission.data_directory.split(/\//)[@submission.data_directory.split(/\//).size - 1]}"
    @start_date = Time.now.strftime("%d %B %Y")
    attachments['bioisis_deposit.pdf'] = File.read(file)
    mail(:to => recipient.email, :subject => "New BioIsis Submission Link", :bcc => 'robert_p_rambo@hotmail.com')
  end

  def save_and_exit(recipient)
     @submission = recipient
     @link = "http://www.bioisis.net/deposition/#{@submission.data_directory.split(/\//)[@submission.data_directory.split(/\//).size - 1]}"
     @start_date = nice_date(@submission.created_at)
     @remaining = nice_date(@submission.created_at + 7.days)
     recipient.email = @submission.email
     mail(:to => recipient.email, :subject => "BioIsis Deposit Saved for #{nice_date(@submission.created_at)}: Use Link To Return", :bcc => 'robert_p_rambo@hotmail.com')
  end
  
  def deposit(recipient)
     @submission = recipient
     @link = "http://www.bioisis.net/deposition/#{@submission.data_directory.split(/\//)[@submission.data_directory.split(/\//).size - 1]}"
     @start_date = Time.now.strftime("%d %B %Y")
     mail(:to => recipient.email, :subject => "BioIsis Deposit Complete", :bcc => 'robert_p_rambo@hotmail.com')
  end
  
  def send_update_notice(email, scatter_update)
     @update = scatter_update   
     mail(:to => email, :subject => "Scatter #{scatter_update.version} Released")    
  end

  def send_me_notice(download)
    @download = download    
    
    @user = User.find_by_id(@download.user_id)      
    
    mail(:to => 'robert_p_rambo@hotmail.com', :subject => "Scatter Download #{download.institution}") do |format|
      format.html
      format.text
    end
  end
  
  private
  def nice_date(date)
    h date.strftime("%d %B %Y")
  end  
  
end

