class AddColumnsToScatterUpdates < ActiveRecord::Migration
  def change
        add_column(:scatter_updates, :zipfile_file_name, :string)
        add_column(:scatter_updates, :zipfile_content_type, :string)        
        add_column(:scatter_updates, :zipfile_file_size, :integer)                
        add_column(:scatter_updates, :zipfile_updated_at, :datetime)
  end
end
