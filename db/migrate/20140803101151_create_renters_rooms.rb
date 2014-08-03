class CreateRentersRooms < ActiveRecord::Migration
  def change
    create_table :renters_rooms do |t|
      t.string :room_code
      t.string :building_code
      t.string :clientcorp_room_cd
      t.string :clientcorp_building_cd
      t.string :store_code
      t.string :store_name
      t.string :building_name
      t.string :real_building_name
      t.string :real_room_no
      t.string :floor
      t.string :building_type
      t.string :pref_code
      t.string :pref_name
      t.string :picture_top
      t.string :zumen
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
    
    add_column :rooms, :renters_room_id, :integer 
  end
end
