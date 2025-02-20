class LikesController < ApplicationController
  before_action :authenticate_user

  def create
    @blog = Blog.find(params[:blog_id])
    @like = current_user.likes.build(blog: @blog)

    if @like.save
      redirect_to @blog, notice: "Blog liked!"
    else
      redirect_to @blog, alert: "Error liking blog."
    end
  end

  def destroy
    @like = current_user.likes.find(params[:id])
    @blog = @like.blog
    @like.destroy

    redirect_to @blog, notice: "Blog unliked!"
  end
end
