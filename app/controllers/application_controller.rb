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
  
  private

  # ログイン認証を行います。
  def check_logined

    if session[:biru_user]
      user_id = session[:biru_user]
	  elsif params[:user_id]
      user_id = params[:user_id].to_i
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
