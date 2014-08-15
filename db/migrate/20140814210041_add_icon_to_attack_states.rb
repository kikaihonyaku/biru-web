class AddIconToAttackStates < ActiveRecord::Migration
  def change
    add_column :attack_states, :icon, :string
  end
end
