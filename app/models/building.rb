# -*- encoding :utf-8 -*-
class Building < ActiveRecord::Base
  acts_as_gmappable
  
  # belongs_to :biru_marker
  has_many :trusts
  has_many :owners, :through=>:trusts
  belongs_to :shop
  belongs_to :build_type
  has_many :rooms

  attr_accessible :address, :code, :name, :shop_id, :manage_type_id, :build_type_id, :icon, :room_num, :manage_icon, :memo, :building_rank_id, :self_type, :tmp_build_type_icon, :build_day

  # デフォルトスコープを定義
  #default_scope where(:delete_flg => false).includes(:shop).includes(:build_type).includes(:trusts).includes(:trusts => :owner)
  # ↑ 最初からスコープでincludesを指定しようと思ったが、管理では使うが募集では不要な結合なので、使う検索の時に別途結合するようにする。
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
