class Item < ActiveRecord::Base
  attr_accessible :code, :name
  has_many :monthly_statements
end
