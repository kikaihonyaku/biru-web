class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_filter :auth
  before_filter :check_logined
  
  private
#  def auth
#    authenticate_or_request_with_http_basic do |user,pass|
#      user == 'user' && pass == 'pass'
#    end
#  end

  # ログイン認証を行います。
  def check_logined
    
    if session[:biru_user] then
      begin 
        @biru_user = BiruUser.find(session[:biru_user])
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end
    
    unless @biru_user
      flash[:referer] = request.fullpath
      p flash[:referer]
      redirect_to :controller => 'login', :action => 'index'
    end
    
  end

  # 管理／募集画面で、検索結果の初期表示を制御するのに使用します。
  # search_type 1:建物 2:貸主 を初期表示
  def search_result_init(search_type)
    @search_type = search_type
    @tab_search = ""
    @tab_result = "active in"
  end

end
