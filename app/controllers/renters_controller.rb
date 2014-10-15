#-*- encoding:utf-8 -*-
require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'

class RentersController < ApplicationController
  
  respond_to :html, :json
  
  def index
    @data_update = DataUpdateTime.find_by_code("310")
    @batch_list = WorkRentersRoom.group(:batch_cd).select(:batch_cd).order("batch_cd desc")
  end
  
  # 画像一覧を表示します
  def pictures
    @room = Room.find(params[:id])
    @room_renters = RentersRoom.find(@room.renters_room_id)
  end
  
  
  def search
    
    @search_building_cd = params[:building_cd]
    
    # レンターズAPIを呼び出し
    url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&clientcorp_building_cd=#{@search_building_cd}")
    xml = open(url).read
    doc = REXML::Document.new(xml)
    
    # 物件名取得
    biru_nm = doc.elements['results/room/real_building_name']
    if biru_nm 
      @building_name = biru_nm.text
    end
    
    image_url = doc.elements['results/room/picture/large_url']
    if image_url 
      @image_url = image_url.text
    end

    @accesses = doc.elements['results/room/access']
    
    # 紐づく写真を取得
  end
  
  
end
