class ChangeVarCharToTextExperiments < ActiveRecord::Migration
  def up
    change_column(:experiments, :publication, :text)
  end

  def down
    change_column(:experiments, :publication, :string)
  end
end
