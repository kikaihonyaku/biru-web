class Line < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :code, :name
  has_many :stations
end
