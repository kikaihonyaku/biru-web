class CreateVacantRooms < ActiveRecord::Migration
  def change
    create_table :vacant_rooms do |t|
      t.string :yyyymm
      t.integer :room_id
      t.integer :shop_id
      t.integer :building_id
      t.integer :manage_type_id
      t.integer :room_layout_id
      t.string :vacant_start_day
      t.integer :vacant_cnt
      t.timestamps
    end
  end
end
