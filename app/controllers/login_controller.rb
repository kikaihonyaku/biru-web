#-*- encoding:utf-8 -*-
class LoginController < ApplicationController
  skip_before_filter :check_logined
  
  def auth
    biru_user = BiruUser.authenticate(params[:code], params[:password])
    if biru_user
      session[:biru_user] = biru_user.id
      redirect_to params[:referer]
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
