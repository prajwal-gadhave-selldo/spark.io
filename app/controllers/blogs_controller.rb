class BlogsController < ApplicationController
  before_action :authenticate_user, except: [ :index, :show ]
  before_action :set_blog, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner, only: [ :edit, :update, :destroy ]

  def index
    @current_user = current_user ? current_user : "guest"
    @blogs = current_user ? BlogsService.index(current_user) : Blog.includes(:user).order(created_at: :desc)
  end

  def show
    @current_user = current_user ? current_user : "guest"
    @comment = Comment.new
    @comments = @blog.comments.includes(:user).order(created_at: :desc)
  end

  def new
    @blog = Blog.new
  end

  def create
    result = BlogsService.create(current_user, blog_params)
    @blog = result[:blog]

    if result[:success]
      redirect_to @blog, notice: "Blog was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    result = BlogsService.update(@blog, blog_params)
    @blog = result[:blog]

    if result[:success]
      redirect_to @blog, notice: "Blog was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    BlogsService.destroy(@blog)
    redirect_to blogs_path, notice: "Blog was successfully deleted."
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :content)
  end

  def set_blog
    result = BlogsService.fetch(params[:id])

    if result[:success]
      @blog = result[:blog]
    else
      redirect_to root_path, alert: result[:error]
    end
  end

  def ensure_owner
    unless BlogsService.owner?(@blog, current_user)
      redirect_to blogs_path, alert: "You are not authorized to perform this action."
    end
  end
end
