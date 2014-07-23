class RemoveAttackStateFromBuildings < ActiveRecord::Migration
  def change
    remove_column :buildings, :attack_state_id
  end
end
