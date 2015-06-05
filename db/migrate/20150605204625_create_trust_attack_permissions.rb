class CreateTrustAttackPermissions < ActiveRecord::Migration
  def change
    create_table :trust_attack_permissions do |t|

      t.integer :holder_user_id, :class_name => 'BiruUser'
      t.integer :permit_user_id, :class_name => 'BiruUser'

      t.timestamps
    end
  end
end
