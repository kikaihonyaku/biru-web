class CreateTrustAttackStateHistories < ActiveRecord::Migration
  def change
    create_table :trust_attack_state_histories do |t|
      t.integer :trust_id
      t.integer :month
      t.integer :attack_state_from_id
      t.integer :attack_state_to_id
      t.timestamps
    end
  end
end
