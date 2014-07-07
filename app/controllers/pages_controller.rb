class PagesController < ApplicationController
  skip_filter :auth # バッチでこのページに定期的にアクセスするためここでは認証が行われないようにする。
  def index
  end
end
