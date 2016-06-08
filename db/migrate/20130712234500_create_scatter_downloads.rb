class CreateScatterDownloads < ActiveRecord::Migration
  def up
    create_table :scatter_downloads do |t|
      t.string :institution
      t.string :country
      t.string :ip_address
      t.string :status
      t.string :version
      t.integer :user_id      
    end
  end

  def down
     drop_table :scatter_downloads
  end
end
