# -*- encoding :utf-8 -*-
class Owner < ActiveRecord::Base
  acts_as_gmappable

  attr_accessible :address, :code, :name, :memo, :attack_code, :dm_delivery,  :honorific_title, :postcode, :biru_user_id, :tel, :kana

  belongs_to :biru_user
  has_many :trusts
  has_many :documents

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
  
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |owner|
        csv << owner.attributes.values_at(*column_names)
      end
    end
  end
  
  
end
