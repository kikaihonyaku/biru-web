class AddColumnNoticeToRentersRooms < ActiveRecord::Migration
  def change
    add_column :work_renters_rooms, :notice_a, :string
    add_column :work_renters_rooms, :notice_b, :string
    add_column :work_renters_rooms, :notice_c, :string
    add_column :work_renters_rooms, :notice_d, :string
    add_column :work_renters_rooms, :notice_e, :string
    add_column :work_renters_rooms, :notice_f, :string


    add_column :renters_rooms, :notice_a, :string
    add_column :renters_rooms, :notice_b, :string
    add_column :renters_rooms, :notice_c, :string
    add_column :renters_rooms, :notice_d, :string
    add_column :renters_rooms, :notice_e, :string
    add_column :renters_rooms, :notice_f, :string
  end
end
