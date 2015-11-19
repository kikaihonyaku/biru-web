class CreateRentersReports < ActiveRecord::Migration
  def change
    create_table :renters_reports do |t|
      t.integer :renters_room_id
      t.integer :renters_building_id
      t.string  :room_code
      t.string  :building_code
      t.float   :latitude
      t.float   :longitude
      t.string :store_code
      t.string :store_name
      t.string :real_building_name
      t.string :real_room_no
      t.string :vacant_div
      t.string :enter_ym
      t.string :address
      t.string :notice_a
      t.string :notice_b
      t.string :notice_c
      t.string :notice_d
      t.string :notice_e
      t.string :notice_f
      t.string :notice_g
      t.string :notice_h
      t.integer :madori_renters_madori
      t.integer :gaikan_renters_gaikan
      t.integer :naikan_renters_kitchen
      t.integer :naikan_renters_toilet
      t.integer :naikan_renters_bus
      t.integer :naikan_renters_living
      t.integer :naikan_renters_washroom
      t.integer :naikan_renters_porch
      t.integer :naikan_renters_scenery
      t.integer :naikan_renters_equipment
      t.integer :naikan_renters_etc
      t.integer :gaikan_etc_renters_entrance
      t.integer :gaikan_etc_renters_common_utility
      t.integer :gaikan_etc_renters_raising_trees
      t.integer :gaikan_etc_renters_parking
      t.integer :gaikan_etc_renters_etc
      t.integer :gaikan_etc_renters_layout
      t.integer :syuuhen_renters_syuuhen
      t.integer :renters_all
      
      t.integer :suumo_all
      t.integer :suumo_madori
      t.integer :suumo_gaikan
      t.integer :suumo_naikan
      t.integer :suumo_gaikan_etc
      t.integer :suumo_syuuhen
      
      
      t.boolean :sakimono_flg
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
  end
end
