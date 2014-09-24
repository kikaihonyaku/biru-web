class RentersBuilding < ActiveRecord::Base
  has_many :renters_rooms
  
  # attr_accessible :title, :body
  default_scope where(:delete_flg => false)
  
end
