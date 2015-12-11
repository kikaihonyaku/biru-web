#-*- encoding:utf-8 -*-
class PagesController < ApplicationController
  # skip_filter :auth # バッチでこのページに定期的にアクセスするためここでは認証が行われないようにする。
  def index
  end
  
  def error_page
  end
  
  def iss
    
    @ridirect_type = nil
    @str = "不正なパラメータです"

    # パラメータチェック
    if params[:owner] && num_check(params[:owner])
      
      owner = Owner.find_by_code(params[:owner])
      unless owner
        @str = "家主CD #{params[:owner]}　は存在しません"
      else
        @str = "オーナー詳細画面 を起動中.....しばらくお待ちください"
        @ridirect_type = :owner
        @id = owner.id.to_s
      end

    elsif params[:building] && num_check(params[:building])
      
      building = Building.find_by_code(params[:building])
      
      unless building
        @str = "建物CD #{params[:building]}　は存在しません"
      else
        @str = "建物詳細画面 を起動中.....しばらくお待ちください"
        @ridirect_type = :building
        @id = building.id.to_s
      end
    end 
    
    render :layout=>'simple'
  end
  
  
  def num_check(str_num)
    str_num =~ /^\d+$/
  end
  
end

