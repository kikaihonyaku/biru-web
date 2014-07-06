class CreateAttackStates < ActiveRecord::Migration
  def change
    create_table :attack_states do |t|
      t.string "code"
      t.string "name"
      t.integer "order"
      t.timestamps
    end
  end
end
