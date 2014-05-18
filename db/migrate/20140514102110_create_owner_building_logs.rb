class CreateOwnerBuildingLogs < ActiveRecord::Migration
  def change
    create_table :owner_building_logs do |t|
      
      t.integer :owner_id
      t.integer :building_id
      t.integer :trust_id
      t.text :message
      t.integer :biru_user_id
      t.boolean :delete_flg, :default=>false

      t.timestamps
    end
  end
end
