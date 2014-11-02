class AddIndexToAllTables < ActiveRecord::Migration
  def change
    
    add_index :biru_user_monthlies, :biru_user_id
    add_index :building_routes, :building_id
    add_index :building_routes, :station_id
    add_index :buildings, :biru_user_id
    add_index :data_update_times, :biru_user_id
    add_index :dept_group_details, :dept_group_id
    add_index :dept_group_details, :dept_id
    add_index :dept_groups, :busyo_id
    add_index :depts, :busyo_id
    add_index :lease_contracts, :building_id
    add_index :lease_contracts, :room_id
    add_index :login_histories, :biru_user_id
    add_index :owner_approaches, :owner_id
    add_index :owner_approaches, :biru_user_id
    add_index :owner_building_logs, :owner_id
    add_index :owner_building_logs, :building_id
    add_index :owner_building_logs, :trust_id
    add_index :owner_building_logs, :biru_user_id
    add_index :owners, :owner_rank_id
    add_index :owners, :biru_user_id
    add_index :renters_room_pictures, :renters_room_id
    add_index :rooms, :room_type_id
    add_index :rooms, :room_layout_id
    add_index :rooms, :trust_id
    add_index :rooms, :manage_type_id
    add_index :rooms, :building_id
    add_index :rooms, :renters_room_id
    add_index :stations, :line_id
    add_index :trust_attack_state_histories, :trust_id
    add_index :trust_attack_state_histories, :attack_state_from_id
    add_index :trust_attack_state_histories, :attack_state_to_id
    add_index :trust_attack_state_histories, :manage_type_id
    add_index :vacant_rooms, :room_id
    add_index :vacant_rooms, :shop_id
    add_index :vacant_rooms, :building_id
    add_index :vacant_rooms, :manage_type_id
    add_index :vacant_rooms, :room_layout_id

  end
end
