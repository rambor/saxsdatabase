class AddCreatedOnToScatterDownloads < ActiveRecord::Migration
  def change
    add_column(:scatter_downloads, :created_at, :datetime)
    add_column(:scatter_downloads, :updated_at, :datetime)    
  end
end
