class AddUserToTrusts < ActiveRecord::Migration
  def change
    remove_column :buildings, :main_employee_id
    add_column :trusts, :biru_user_id, :integer
  end
end
