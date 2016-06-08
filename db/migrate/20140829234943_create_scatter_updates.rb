class CreateScatterUpdates < ActiveRecord::Migration
  def change
    create_table :scatter_updates do |t|
      t.text :comments
      t.string :version
      t.string :title
      
      t.timestamps
    end
  end
end
