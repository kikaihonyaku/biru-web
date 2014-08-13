class RenameOrderToAttackStates < ActiveRecord::Migration
  def up
    rename_column :attack_states, :order, :disp_order
  end

  def down
    rename_column :attack_states, :disp_order, :order 
  end
end
