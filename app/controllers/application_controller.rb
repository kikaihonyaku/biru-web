class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :auth
  private
  def auth
    authenticate_or_request_with_http_basic do |user,pass|
      user == 'user' && pass == 'pass'
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
