class BiruUserMonthly < ActiveRecord::Base
  attr_accessible :biru_user_id, :month, :trust_plan_visit, :trust_plan_dm, :trust_plan_tel
  belongs_to :biru_user
end
