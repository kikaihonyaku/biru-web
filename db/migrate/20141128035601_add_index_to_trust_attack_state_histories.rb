class AddIndexToTrustAttackStateHistories < ActiveRecord::Migration
  def change
  	add_index :trust_attack_state_histories, :month
  end
end
