class OwnerBuildingLog < ActiveRecord::Base
  attr_accessible :owner_id, :building_id, :trust_id, :message, :biru_user_id
  
  belongs_to :owner
  belongs_to :building
  belongs_to :trust
  belongs_to :biru_user
  
end
