class AddScoreToAttackState < ActiveRecord::Migration
  def change
    add_column :attack_states, :score, :integer, :defalut=>0
  end
end
