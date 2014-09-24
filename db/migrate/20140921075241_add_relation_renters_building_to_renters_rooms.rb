class AddRelationRentersBuildingToRentersRooms < ActiveRecord::Migration
  def change
  	add_column :renters_rooms, :renters_building_id, :integer
  	add_index :renters_rooms, :building_code
  	add_index :renters_rooms, :renters_building_id
  end
end
