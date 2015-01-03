class AddTorihikiModeToRenters < ActiveRecord::Migration
  def change
    add_column :work_renters_rooms, :torihiki_mode, :string
    add_column :renters_rooms, :torihiki_mode, :string
    add_column :renters_rooms, :torihiki_mode_sakimono, :boolean
    
    add_index :renters_rooms, :torihiki_mode
    add_index :renters_rooms, :torihiki_mode_sakimono
  end
end
