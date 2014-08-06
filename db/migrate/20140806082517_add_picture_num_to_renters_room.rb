class AddPictureNumToRentersRoom < ActiveRecord::Migration
  def change
    add_column :renters_rooms, :picture_num, :integer ,:default=>0
  end
end
