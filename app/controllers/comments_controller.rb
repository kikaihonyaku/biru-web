class CommentsController < ApplicationController
  def index
    
    @code = params[:code]
    @sub_code = params[:sub_code]
    @comment_type = params[:comment_type]
    @comments = initialize_grid(Comment.joins(:biru_user).where("comments.code = " + @code.to_s ).where("comments.sub_code = " + @sub_code.to_s).where("comment_type = " + @comment_type.to_s ).order("comments.created_at desc") )
    
    render :layout=>'popup'
  end
  
  def regist
    
    @code = params[:comment][:code]
    @sub_code = params[:comment][:sub_code]
    @comment_type = params[:comment][:comment_type]
    
    comment = Comment.new
    comment.code = @code
    comment.sub_code = @sub_code
    comment.comment_type = @comment_type
    comment.content = params[:comment][:content]
    comment.biru_user_id = @biru_user.id
    comment.save!
    
    redirect_to :action=>'index', :code=>@code, :sub_code=>@sub_code, :comment_type=>@comment_type
  end
end
