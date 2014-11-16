class TrustMaintenance < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :trust
  default_scope where(:delete_flg => false)
  
  
end
