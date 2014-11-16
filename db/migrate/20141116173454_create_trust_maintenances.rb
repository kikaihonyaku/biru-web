class CreateTrustMaintenances < ActiveRecord::Migration
  def change
    create_table :trust_maintenances do |t|
      t.integer :trust_id
      t.integer :idx
      t.string :code
      t.string :name
      t.integer :price
      t.boolean :delete_flg, :default=>false

      t.timestamps
    end
    
    add_index :trust_maintenances, :trust_id
    add_index :trust_maintenances, :delete_flg
  end
end
