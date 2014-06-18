#-*- encoding:utf-8 -*-
class LoginController < ApplicationController
  skip_before_filter :check_logined
  
  def auth
    biru_user = BiruUser.authenticate(params[:code], params[:password])
    if biru_user
      
    	# ログの保存
    	log = LoginHistory.new
    	log.biru_user_id = biru_user.id
    	log.code = biru_user.code
    	log.name = biru_user.name
    	log.save!
    	
      session[:biru_user] = biru_user.id
      
    	# TODO:refererがブランクだったらルートに飛ばす。      
      if params[:referer].blank?
        redirect_to '/managements/index'
      else
        redirect_to params[:referer]
      end
      
    else
      flash.now[:referer] = params[:referer]
      @error = '社員番号またはパスワードが違います'
      render 'index'
    end
  end
  
  def logout
    reset_session
    redirect_to '/'
  end


end
