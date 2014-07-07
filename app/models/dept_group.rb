class DeptGroup < ActiveRecord::Base
  attr_accessible :name
  has_many :dept_group_details
end
