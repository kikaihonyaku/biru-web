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
      t.string :room_no
      t.string :real_building_name
      t.string :real_room_no
      t.string :floor
      t.string :building_type
      t.string :structure
      t.string :construction
      t.string :room_num
      t.string :address
      t.string :detail_address
      t.string :vacant_div
      t.string :enter_ym
      t.string :new_status
      t.string :completion_ym
      t.string :square
      t.string :square
      t.string :room_layout_type
      t.string :picture_top
      t.string :zumen
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
    
    add_column :rooms, :renters_room_id, :integer 
  end
end
