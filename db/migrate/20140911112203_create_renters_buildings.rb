class CreateRentersBuildings < ActiveRecord::Migration
  def change
    create_table :renters_buildings do |t|

      t.string :building_cd
      t.string :building_name
      t.string :real_building_name
      t.string :clientcorp_building_cd
      t.string :building_type
      t.string :structure
      t.string :construction
      t.string :room_num
      t.string :address
      t.float  :latitude
      t.float  :longitude
      t.boolean :gmaps
      t.string :completion_ym
      t.boolean :delete_flg
      t.timestamps
    end
  end
end
