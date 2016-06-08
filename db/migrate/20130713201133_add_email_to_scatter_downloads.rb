class AddEmailToScatterDownloads < ActiveRecord::Migration
  def change
    add_column :scatter_downloads, :email, :string    
  end
end
