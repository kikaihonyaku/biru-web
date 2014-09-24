class RentersRoom < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :renters_building
  has_many :renters_room_pictures
  default_scope where(:delete_flg => false)
  
end
