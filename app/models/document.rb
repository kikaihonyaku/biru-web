class Document < ActiveRecord::Base
  attr_accessible :owner_id, :building_id, :file_name, :biru_user_id
  
  belongs_to :owner
  belongs_to :building
  belongs_to :biru_user
  

  # 2015.08.20 paper_clip
  # attr_accessible :doc_file
  # has_attached_file :doc_file, style: { medium: "300x300>", thumb: "100x100>" }
  # validates_attachment :doc_file, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }
end
