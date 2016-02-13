class Comment < ActiveRecord::Base
  attr_accessible :biru_user_id, :code, :comment_type, :content, :delete_flg
  
  default_scope where(:delete_flg => false)
  belongs_to :biru_user
end
