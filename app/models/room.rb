class Room < ActiveRecord::Base
  attr_accessible :code, :name, :room_type, :room_layout, :trust, :manage_type, :rent

  # デフォルトスコープを定義
  default_scope where(:delete_flg => false)

  belongs_to :building
  belongs_to :room_type
  belongs_to :room_layout
  belongs_to :trust
  belongs_to :manage_type

end
