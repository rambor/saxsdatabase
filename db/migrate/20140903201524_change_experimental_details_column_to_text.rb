class ChangeExperimentalDetailsColumnToText < ActiveRecord::Migration
  def up
    change_column(:experiments, :experimental_details, :text, :default => nil)
  end

  def down
    change_column(:experiments, :experimental_details, :string, :default => "single concentration")
  end

end
