class Station < ActiveRecord::Base

  acts_as_gmappable

  # attr_accessible :title, :body
  attr_accessible :code, :name, :line_code, :address
  belongs_to :line

  def gmaps4rails_address
   "#{self.address}"
  end

end
