class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :auth
  private
  def auth
    authenticate_or_request_with_http_basic do |user,pass|
      user == 'user' && pass == 'pass'
    end
  end
end
