#-*- encoding:utf-8 -*-

class OwnerApproach < ActiveRecord::Base
  attr_accessible :owner_id, :approach_date, :approach_kind_id, :content, :biru_user_id, :delete_flg

  belongs_to :owner
  belongs_to :approach_kind
  belongs_to :biru_user

  validates :approach_date, :presence => {:message =>'アプローチ日を入力してください'}
  validates :content, :presence => {:message =>'内容を入力してください'}
end
