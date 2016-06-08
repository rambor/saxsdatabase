class ChangeResetPasswordSentAtInUsers < ActiveRecord::Migration
  def up
    change_column :users, :reset_password_sent_at, :datetime 
  end

  def down
    change_column :users, :reset_password_sent_at, :time
  end
end
