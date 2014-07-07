class Dept < ActiveRecord::Base
  attr_accessible :busyo_id, :code, :name, :delete_flg
  has_many :dept_group_details
  has_many :monthly_statements
end
