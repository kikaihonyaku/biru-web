class AddIndexToWorkRentersRooms < ActiveRecord::Migration
  def change
    add_index :work_renters_rooms, :batch_cd
    add_index :work_renters_rooms, :building_cd
    
    add_index :work_renters_room_pictures, :batch_cd
    add_index :work_renters_room_pictures, :batch_cd_idx
    add_index :work_renters_room_pictures, :batch_picture_idx
  end
end
