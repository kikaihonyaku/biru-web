class RentersReport < ActiveRecord::Base
  
  belongs_to :renters_room
  belongs_to :renters_building
  
  # attr_accessible :title, :body

  default_scope where(:delete_flg => false)

end
