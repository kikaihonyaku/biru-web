class BuildingRoute < ActiveRecord::Base
  attr_accessible :bus, :minutes
  belongs_to :building
  belongs_to :station
end
