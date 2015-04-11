class AddNotice7ToRentersRooms < ActiveRecord::Migration
  def change
    add_column :work_renters_rooms, :notice_g, :string
    add_column :work_renters_rooms, :notice_h, :string


    add_column :renters_rooms, :notice_g, :string
    add_column :renters_rooms, :notice_h, :string
  end
end
