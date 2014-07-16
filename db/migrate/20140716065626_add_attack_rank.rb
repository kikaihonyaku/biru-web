class AddAttackRank < ActiveRecord::Migration
  def change
    add_column :trusts, :attack_state_id, :integer
  end
end
