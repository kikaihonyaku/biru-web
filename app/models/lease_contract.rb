class LeaseContract < ActiveRecord::Base
  attr_accessible :code, :building_id, :room_id, :rent, :start_date, :leave_date, :lease_month
  belongs_to :building
  belongs_to :room
end
