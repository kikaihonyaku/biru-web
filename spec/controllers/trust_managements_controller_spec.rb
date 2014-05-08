# -*- encoding:utf-8 -*-
require 'spec_helper'

describe TrustManagementsController do
  
  # 事前登録
  before(:each) do
    
    # 営業所データを作る
    @shop = Shop.new
    @shop.name = 'テスト営業所'
    @shop.gmaps = true
    @shop.save!
    
    # オーナーデータを作る
    @owner = Owner.new
    @owner.name = "takashi"
    @owner.code = "001"
    @owner.gmaps = true
    @owner.save!
    
    # 物件データを作る
    @b01 = Building.new
    @b01.attack_code = '0001'
    @b01.name = 'ル・アンジェリーク'
    @b01.shop_id = @shop.id
    @b01.gmaps = true
    @b01.save!
    
    @b02 = Building.new
    @b02.attack_code = '0002'
    @b02.name = 'がレーネー'
    @b02.shop_id = @shop.id
    @b02.gmaps = true
    @b02.save!
    
    
    # 委託CDで結びつける
    @trust01 = Trust.new
    @trust01.owner_id = @owner.id
    @trust01.building_id = @b01.id
    @trust01.save!
    
    @trust02 = Trust.new
    @trust02.owner_id = @owner.id
    @trust02.building_id = @b01.id
    @trust02.save!
    
      
    # login状態にする
    biru_user = BiruUser.new
    biru_user.code = '00002'
    biru_user.name = 'test'
    biru_user.password = 'password'
    biru_user.save
    session[:biru_user] = biru_user.id
    
  end
  
  describe '#index' do
    render_views
  
    before(:each) do
      # これが大事
      get :index
    end
    
    it '応答がサクセスであること' do
      response.should be_success
    end
    
    it '一覧の件数が２件であること' do
      assigns[:trust_arr].count.should eq(2)
    end
  
    it 'indexビューを読み込んでいること' do
      response.should render_template('index')
    end
      
  end
  
  describe '#owner_show' do
    
    before(:each) do
      get :owner_show, :id => 1 
    end

    it '応答がサクセスであること' do
      response.should be_success
    end
    
    it 'パラメータが引きわたっていること' do
      assigns[:id].should eq("1")
    end
    
  end
  
  describe '#update' do
    render_views
    
    before(:each) do
      post :owner_update, :id => 1
    end
    
    it 'upateができること' do
      # post :owner_update, :id => 1
    end
    
    it 'またOwnerShowのテンプレートが表示されること' do
      #response.should render_template('owner_show')
      #response.should be_success
      response.should redirect_to(:action => :owner_show)
    end 
  end
  
  
  
end
