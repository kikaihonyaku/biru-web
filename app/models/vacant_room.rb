class VacantRoom < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :building
  belongs_to :room_layout
  belongs_to :manage_type
  belongs_to :shop
  belongs_to :room
end
