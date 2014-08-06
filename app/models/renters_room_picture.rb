class RentersRoomPicture < ActiveRecord::Base
  # attr_accessible :title, :body
  
  default_scope where(:delete_flg => false)
  
  belongs_to :renters_room
end
