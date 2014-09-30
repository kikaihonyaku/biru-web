class AddUserIndexToTrusts < ActiveRecord::Migration
  def change
  	add_index :trusts, :biru_user_id
  end
end
