class AddIndexToRentersRooms < ActiveRecord::Migration
  def change
    add_index :renters_rooms, :store_code
  end
end
