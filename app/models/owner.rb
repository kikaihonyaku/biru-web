# -*- encoding :utf-8 -*-
class Owner < ActiveRecord::Base
  acts_as_gmappable

  attr_accessible :address, :code, :name, :memo, :attack_code, :dm_delivery

  has_many :trusts

  # デフォルトスコープを定義
  default_scope where(:delete_flg => false)

  def gmaps4rails_address
   "#{self.address}"
  end

  def gmaps4rails_infowindow
    "<h3>#{name}</h3>"
  end

  def gmaps4rails_sidebar
    "<span class=""foo"">#{name}</span>"
  end

end
