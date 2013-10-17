class OwnersController < ApplicationController
  def index
    
  end

  # popupからアップデートを実行する。
  def update
    @owner = Owner.find(params[:id])

    if @owner.update_attributes(params[:owner])
    end
  end

end
