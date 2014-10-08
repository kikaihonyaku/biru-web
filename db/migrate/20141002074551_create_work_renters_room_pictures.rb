class CreateWorkRentersRoomPictures < ActiveRecord::Migration
  def change
    create_table :work_renters_room_pictures do |t|
      t.string :batch_cd
      t.integer :batch_cd_idx
      t.string :room_cd
	    t.integer :batch_picture_idx
	    t.string :room_cd
			t.string :true_url
			t.string :large_url
			t.string :mini_url
			t.string :main_category_code
			t.string :sub_category_code
			t.string :sub_category_name
			t.string :caption
			t.string :priority
			t.string :entry_datetime
      t.timestamps
    end
    
    add_column :renters_room_pictures, :main_category_code, :string
    add_column :renters_room_pictures, :sub_category_code, :string
    add_column :renters_room_pictures, :sub_category_name, :string
    add_column :renters_room_pictures, :caption, :string
    add_column :renters_room_pictures, :priority, :string
    add_column :renters_room_pictures, :entry_datetime, :string
    
  end
end
