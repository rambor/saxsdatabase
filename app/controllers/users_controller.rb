class UsersController < ApplicationController
   before_filter :authenticate_user!
   
   def index
    @users_size = User.count
    @users = User.paginate :per_page => 25, :page => params[:page], :order => "email DESC"
    
    authorize! :manage, @users    
    respond_to do |format|
     format.html  
    end
   end
   
   def edit
     @user = User.find_by_id(params[:id])

     respond_to do |format|
      format.html  
     end
   end
   
   def update
     @user = User.find_by_id(params[:id])

     if @user.update_attributes(params[:user])
       flash[:notice] = 'Successfully updated.'    
       redirect_to :action => 'index'
     end
     flash[:notice] = 'Entry was successfully updated.'
   end   
   
   def destroy
     @user = User.find_by_id(params[:id])
     if @user.destroy
         redirect_to :action =>'index'
     end
   end   
end
