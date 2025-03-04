class CommentsController < ApplicationController
  before_action :authenticate_user

  def create
    begin
    @blog = Blog.find(params[:blog_id])
    @comment = @blog.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save

      redirect_to @blog, notice: "Comment was successfully added."
    else
      redirect_to @blog, notice: "Error adding comment."
    end

    rescue ActiveRecord::RecordNotFound
      redirect_to blogs_path, alert: "Blog not found."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
