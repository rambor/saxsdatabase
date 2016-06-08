class AddPiToScatterDownloads < ActiveRecord::Migration
  def change
    add_column :scatter_downloads, :pi, :string
  end
end
