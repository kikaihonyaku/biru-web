class ModAttackRegistColumn01 < ActiveRecord::Migration
  def change
    remove_column :owners, :main_employee_id
    add_column :owners, :biru_user_id, :integer
    add_column :buildings, :biru_user_id, :integer
  end
end
