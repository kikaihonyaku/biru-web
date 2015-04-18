# -*- coding:utf-8 -*-

require 'kconv'
require 'date'
require "moji"
require 'digest/md5'

class ApplicationController < ActionController::Base
  protect_from_forgery

  # 2014/06/02 
  # change_biru_iconはrailsのformではなくhtmlのformで直接送ってくるから
  # biru_userセッションを参照できない。それによってログインへリダイレクトされると
  # 直前の地図凡例変更のイベントが失われてしまう。change_biru_iconだけは例外扱いとする。
  #
  # 2014/06/02 追記
  # 一度sessionがクリアされてしまうと次検索した時に必ずログイン画面になってしまう。
  # 検索条件もリセットされてしまうので使い勝手が悪いので、managementsコントローラの時は
  # もうチェックしないようにする。（良い対策ができるまで）
  #before_filter :check_logined, :except => ['change_biru_icon', 'search_owners', 'search_buildings', 'bulk_search_text'] 
  
  # 2014/06/10 paramでuser_idを送るようにして対応できた。
  before_filter :check_logined
  
  # CSV出力する際、Windowsで開くためにShift_JISに変換する。■2014/08/12 当面はpdfで出力するため、文字コードはutf-8に戻す。
  after_filter :change_charset_to_sjis, :if => :csv?
  
  
  # 建物用のハッシュを取得します
  def conv_code_building(user_id, address, name)
    return conv_code(user_id + '_' + address + '_' + name )
  end
  
  # 貸主用のハッシュを取得します
  def conv_code_owner(user_id, address, name)
    return conv_code(user_id + '_' + address + '_' + name )
  end
  
  protected
  def change_charset_to_sjis
    response.body = NKF::nkf('-Ws', response.body)
    headers["Content-Type"] = "text/html; charset=Shift_JIS"
  end  
  
  private

  # ログイン認証を行います。
  def check_logined

    url_param_delete = false
     
    if session[:biru_user]
      user_id = session[:biru_user]
	  elsif params[:user_id]
      user_id = params[:user_id].to_i
    elsif params[:sid]
      user_id = BiruUser.find_by_syain_id(params[:sid])
      url_param_delete = true

      if user_id
    	  # ログの保存
    	  log = LoginHistory.new
    	  log.biru_user_id = user_id.id
    	  log.code = user_id.code
    	  log.name = user_id.name
    	  log.save!      	
      end

    else
			user_id = nil
    end
    
    if user_id then
      begin
				@biru_user = BiruUser.find(user_id)
				session[:biru_user] = @biru_user
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end
    
    unless @biru_user
      flash[:referer] = request.fullpath
      redirect_to :controller => 'login', :action => 'index'
    end
    
    # URLパラメータを消すためにリダイレクトする
#    if url_param_delete
#      endpos = request.fullpath.index("?") - 1
#      redirect_to request.fullpath[0..endpos]
#    end
    
  end

  # 管理／募集画面で、検索結果の初期表示を制御するのに使用します。
  # search_type 1:建物 2:貸主 を初期表示
  def search_result_init(search_type)
    @search_type = search_type
    @tab_search = ""
    @tab_result = "active in"
  end
  
  def trust_managements?
    self.controller_name == 'trust_managements'
  end
  
  def csv?
    return request.original_url.match(/csv/) ? true : false
  end
  
  # 文字列の日付が正しいかチェックします
  def date_check(str_date)

    result = true
    
    begin
      Date.parse(str_date)
    rescue => ex
      result = false
    end  
    
    result
    
  end
  
  # 指定した建物情報を元に、出力用のjavascriptオブジェクトを作成します。
  def buildings_to_gon(buildings)

      @manage_line_color = make_manage_line_list

      if buildings.size == 0
        # 表示する建物が存在しない時
        @owners = []
        @trusts = []
        @owner_to_buildings = {}
        @building_to_owners = {}
        @shops =  Shop.find(:all)
      
      else

        # 建物にマーカーを設定
        set_biru_obj(buildings)
        @buildings = buildings

        # 建物に紐づく貸主／委託契約を取得(合わせて管理方式の絞り込み)
        @shops, @owners, @trusts, @owner_to_buildings, @building_to_owners = get_building_info(buildings)

      end

      gon.buildings = buildings
      gon.owners = @owners # 関連する貸主
      gon.trusts = @trusts # 関連する委託契約
      gon.shops = @shops    # 関連する営業所
      gon.owner_to_buildings = @owner_to_buildings # 建物と貸主をひもづける情報
      gon.building_to_owners = @building_to_owners
      gon.manage_line_color = @manage_line_color
      gon.all_shops = Shop.find(:all)
    
  end

  # 指定された建物に紐づく営業所・貸主・委託情報を取得する
  def get_building_info(buildings)

    shops = []
    owners = []
    trusts = []
    owner_to_buildings = []
    building_to_owners = []

    buildings.each do |biru|

      shops << biru.shop if biru.shop

      biru.trusts.each do |trust|

        trusts << trust

        # 貸主登録
        if trust.owner
          tmp_owner = trust.owner
          owners << tmp_owner

          # 貸主に紐づく建物一覧を作成する。
          owner_to_buildings[tmp_owner.id] = [] unless owner_to_buildings[tmp_owner.id]
          owner_to_buildings[tmp_owner.id] << biru

          # 建物に紐づく貸主一覧を作成する。※本来建物に対するオーナーは１人だが、念のため複数オーナーも対応する。
          building_to_owners[biru.id] = [] unless building_to_owners[biru.id]
          building_to_owners[biru.id] << tmp_owner

        end
      end

    end

    owners.uniq! if owners
    trusts.uniq! if trusts
    shops.uniq! if shops

    return shops, owners, trusts, owner_to_buildings, building_to_owners

  end

  # 管理方式のIDに応じた色リストを作成する
  def make_manage_line_list
    arr = []
    ManageType.all.each do |manage_type|
      arr[manage_type.id] = manage_type.line_color
    end

    return arr
  end
  
  # 建物インスタンスに物件種別・管理方式を設定する。
  def set_biru_obj(buildings)
    buildings.each do |biru|
      
      if biru.build_type
        biru.tmp_build_type_icon = biru.build_type.icon
      else
        # biru.tmp_build_type_icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e4%b8%8d|00FF00|000000'
        biru.tmp_build_type_icon = view_context.image_path('marker_white.png')
      end
      
      if biru.trusts
        biru.trusts.each do |trust|
          if trust.manage_type
            biru.tmp_manage_type_icon = trust.manage_type.icon
          end
        end
      end

    end

  end
  
  
  # アタック建物コードやアタック貸主コードの生成に使用
  # def attack_conv_code(user_id, address, name)
  #
  #   str = user_id.to_s + '_' + address + '_' + name
  #
  #   str = str.gsub(/(\s|　)+/, '')
  #   str = str.upcase
  #   str = Moji.han_to_zen(str.encode('utf-8'))
  #
  #  # ハッシュ化して先頭6文字を取得
  #  return Digest::MD5.new.update(str).to_s[0,5]
  # end
  
  # コード用に変換方法を統一
  def conv_code(str)
    str = str.gsub(/(\s|　)+/, '')
    str = str.upcase
    str = Moji.han_to_zen(str.encode('utf-8'))

   # ハッシュ化
   return Digest::MD5.new.update(str).to_s
  end
  
  # 指定された日のポラスの月度を取得する
  def get_month(cur_date)
    if cur_date.day > 20
      # 日付が21日以降だったら翌月
      cur_date.next_month.strftime("%Y%m")
    else
      # それ以外だったら当月
      cur_date.strftime("%Y%m")
    end
  end
  
  # カレントの月度を返す
  def get_cur_month
    
    # 当月の月を出す。
    if Date.today.day > 20
      # 翌月
      cur_date = Date.today.next_month
    else
      # 当月
      cur_date = Date.today
    end 
    
     month = "%04d%02d"%[cur_date.year.to_s, cur_date.month.to_s]
    
  end
  
  # jqgridの営業所リストを返す
  def jqgrid_combo_shop
    result = ":"
    Shop.order(:group_id,  :area_id).each do |shop|
      result = result + ";" + shop.name + ":" + shop.name
    end
    result
  end
  

  # jqgridの営業所リストを返す
  def jqgrid_combo_shop
    result = ":"
    Shop.order(:group_id,  :area_id).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  # jqgridの建物種別のリストを返す
  def jqgrid_combo_build_type
    result = ":"
    BuildType.find(:all).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  # jqgridの管理方式のリストを返す
  def jqgrid_combo_manage_type
    result = ":"
    ManageType.find(:all).each do |obj|
      result = result + ";" + obj.name + ":" + obj.name
    end
    result
  end

  

end
