class ChangeEmailToBoolean < ActiveRecord::Migration
  def up
      change_column :scatter_downloads, :email, :boolean    
  end

  def down
      change_column :scatter_downloads, :email, :string        
  end
end
