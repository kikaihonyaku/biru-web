class CreateRentersRoomPictures < ActiveRecord::Migration
  def change
    create_table :renters_room_pictures do |t|
      t.integer :renters_room_id
      t.integer :idx
      t.string :true_url
      t.string :large_url
      t.string :mini_url
      t.boolean :delete_flg, :default=>false
      t.timestamps
    end
  end
end
