class DeptGroupDetail < ActiveRecord::Base
 attr_accessible :dept_group_id, :dept_id
  belongs_to :dept
  belongs_to :dept_group
end
