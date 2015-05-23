class CreatePropertyReports < ActiveRecord::Migration
  def change
    create_table :property_reports do |t|

      t.string :shop_code
      t.integer :building_cnt, :default=>0
      t.integer :room_cnt, :default=>0
      t.integer :biru_type_mn_cnt, :default=>0
      t.integer :biru_type_bm_cnt, :default=>0
      t.integer :biru_type_ap_cnt, :default=>0
      t.integer :biru_type_kdt_cnt, :default=>0
      t.integer :biru_type_etc_cnt, :default=>0
      t.integer :trust_mente_junkai_seisou_cnt, :default=>0
      t.integer :trust_mente_kyusui_setubi_cnt, :default=>0
      t.integer :trust_mente_tyosui_seisou_cnt, :default=>0
      t.integer :trust_mente_elevator_hosyu_cnt, :default=>0
      t.integer :trust_mente_bouhan_camera_cnt, :default=>0

      t.integer :room_type_17010_1, :default=>0
      t.integer :room_type_17010_2, :default=>0
      t.integer :room_type_17010_3, :default=>0
      t.integer :room_type_17010_4, :default=>0
      t.integer :room_type_17010_9, :default=>0
      t.integer :room_type_17015_1, :default=>0
      t.integer :room_type_17015_2, :default=>0
      t.integer :room_type_17015_3, :default=>0
      t.integer :room_type_17015_4, :default=>0
      t.integer :room_type_17015_9, :default=>0
      t.integer :room_type_17020_1, :default=>0
      t.integer :room_type_17020_2, :default=>0
      t.integer :room_type_17020_3, :default=>0
      t.integer :room_type_17020_4, :default=>0
      t.integer :room_type_17020_9, :default=>0
      t.integer :room_type_17025_1, :default=>0
      t.integer :room_type_17025_2, :default=>0
      t.integer :room_type_17025_3, :default=>0
      t.integer :room_type_17025_4, :default=>0
      t.integer :room_type_17025_9, :default=>0
      t.integer :room_type_17030_1, :default=>0
      t.integer :room_type_17030_2, :default=>0
      t.integer :room_type_17030_3, :default=>0
      t.integer :room_type_17030_4, :default=>0
      t.integer :room_type_17030_9, :default=>0
      t.integer :room_type_17035_1, :default=>0
      t.integer :room_type_17035_2, :default=>0
      t.integer :room_type_17035_3, :default=>0
      t.integer :room_type_17035_4, :default=>0
      t.integer :room_type_17035_9, :default=>0
      t.integer :room_type_17099_1, :default=>0
      t.integer :room_type_17099_2, :default=>0
      t.integer :room_type_17099_3, :default=>0
      t.integer :room_type_17099_4, :default=>0
      t.integer :room_type_17099_9, :default=>0
      t.integer :biru_age_0005_1, :default=>0
      t.integer :biru_age_0005_2, :default=>0
      t.integer :biru_age_0005_3, :default=>0
      t.integer :biru_age_0005_4, :default=>0
      t.integer :biru_age_0005_9, :default=>0
      t.integer :biru_age_0610_1, :default=>0
      t.integer :biru_age_0610_2, :default=>0
      t.integer :biru_age_0610_3, :default=>0
      t.integer :biru_age_0610_4, :default=>0
      t.integer :biru_age_0610_9, :default=>0
      t.integer :biru_age_1115_1, :default=>0
      t.integer :biru_age_1115_2, :default=>0
      t.integer :biru_age_1115_3, :default=>0
      t.integer :biru_age_1115_4, :default=>0
      t.integer :biru_age_1115_9, :default=>0
      t.integer :biru_age_1620_1, :default=>0
      t.integer :biru_age_1620_2, :default=>0
      t.integer :biru_age_1620_3, :default=>0
      t.integer :biru_age_1620_4, :default=>0
      t.integer :biru_age_1620_9, :default=>0
      t.integer :biru_age_2125_1, :default=>0
      t.integer :biru_age_2125_2, :default=>0
      t.integer :biru_age_2125_3, :default=>0
      t.integer :biru_age_2125_4, :default=>0
      t.integer :biru_age_2125_9, :default=>0
      t.integer :biru_age_2630_1, :default=>0
      t.integer :biru_age_2630_2, :default=>0
      t.integer :biru_age_2630_3, :default=>0
      t.integer :biru_age_2630_4, :default=>0
      t.integer :biru_age_2630_9, :default=>0
      t.integer :biru_age_3135_1, :default=>0
      t.integer :biru_age_3135_2, :default=>0
      t.integer :biru_age_3135_3, :default=>0
      t.integer :biru_age_3135_4, :default=>0
      t.integer :biru_age_3135_9, :default=>0
      t.integer :biru_age_9999_1, :default=>0
      t.integer :biru_age_9999_2, :default=>0
      t.integer :biru_age_9999_3, :default=>0
      t.integer :biru_age_9999_4, :default=>0
      t.integer :biru_age_9999_9, :default=>0

      t.timestamps
    end
  end
end
