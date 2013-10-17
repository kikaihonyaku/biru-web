# -*- encoding:utf-8 -*-
class Trust < ActiveRecord::Base
  belongs_to :building
  belongs_to :owner
  belongs_to :manage_type

  attr_accessible :building_id, :owner_id, :manage_type_id

  # デフォルトスコープを定義
  default_scope where(:delete_flg => false)

end
