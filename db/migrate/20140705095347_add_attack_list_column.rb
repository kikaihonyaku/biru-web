class AddAttackListColumn < ActiveRecord::Migration
  def change
    add_column :owners, :dm_delivery, :boolean, :default=>true
    add_column :owners, :main_employee_id, :integer
    add_column :buildings, :main_employee_id, :integer
    add_column :buildings, :attack_state_id, :integer
    add_column :biru_users, :attack_all_search, :boolean, :default=>false
    
  end
end
