class MonthlyStatement < ActiveRecord::Base
  attr_accessible :dept_id, :item_id, :yyyymm, :plan, :result
  belongs_to :item
  belongs_to :dept
end
