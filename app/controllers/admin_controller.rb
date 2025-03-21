class AdminController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_user, only: [ :show_user, :edit_user, :update_user, :user_activity ]
  before_action :set_blog, only: [ :show_blog, :edit_blog, :update_blog, :destroy_blog ]
  layout "admin"

  def dashboard
    dashboard_data = AdminService.dashboard_data

    @total_users = dashboard_data[:total_users]
    @total_blogs = dashboard_data[:total_blogs]
    @total_comments = dashboard_data[:total_comments]
    @total_likes = dashboard_data[:total_likes]
    @new_users_count = dashboard_data[:new_users_count]
    @user_growth_data = dashboard_data[:user_growth_data]
    @content_data = dashboard_data[:content_data]
    @latest_users = dashboard_data[:latest_users]
    @latest_blogs = dashboard_data[:latest_blogs]
  end

  def activity
    @date_range = params[:range] || "30_days"
    activity_data = AdminService.activity_data(@date_range)

    @start_date = activity_data[:start_date]
    @daily_data = activity_data[:daily_data]
    @active_users = activity_data[:active_users]
    @popular_blogs = activity_data[:popular_blogs]
  end

  def users
    @users = AdminService.filter_users(params)

    respond_to do |format|
      format.html
      format.csv { send_data AdminService.generate_users_csv(@users), filename: "users-#{Date.today}.csv" }
    end
  end

  def show_user
  end

  def edit_user
  end

  def update_user
    result = AdminService.update_user(@user, user_params)

    if result[:success]
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      @user = result[:user]
      render :edit_user, status: :unprocessable_entity
    end
  end

  def user_activity
    activity_data = AdminService.user_activity(@user)

    @blogs = activity_data[:blogs]
    @comments = activity_data[:comments]
    @likes = activity_data[:likes]
  end

  def blogs
    @blogs = AdminService.filter_blogs(params)

    respond_to do |format|
      format.html
      format.csv { send_data AdminService.generate_blogs_csv(@blogs), filename: "blogs-#{Date.today}.csv" }
    end
  end

  def show_blog
  end

  def new_blog
    @blog = Blog.new
  end

  def create_blog
    result = AdminService.create_blog(blog_params, current_user)

    if result[:success]
      redirect_to admin_blogs_path, notice: "Blog was successfully created."
    else
      @blog = result[:blog]
      render :new_blog, status: :unprocessable_entity
    end
  end

  def edit_blog
  end

  def update_blog
    result = AdminService.update_blog(@blog, blog_params)

    if result[:success]
      redirect_to admin_blog_path(@blog), notice: "Blog was successfully updated."
    else
      @blog = result[:blog]
      render :edit_blog, status: :unprocessable_entity
    end
  end

  def destroy_blog
    AdminService.destroy_blog(@blog)
    redirect_to admin_blogs_path, notice: "Blog was successfully deleted."
  end

  private

  def set_user
    result = AdminService.find_user(params[:id])

    if result[:success]
      @user = result[:user]
    else
      redirect_to admin_users_path, alert: result[:error]
    end
  end

  def set_blog
    result = AdminService.find_blog(params[:id])

    if result[:success]
      @blog = result[:blog]
    else
      redirect_to admin_blogs_path, alert: result[:error]
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :excerpt, :category, :status, :featured_image)
  end

  def authorize_admin
    unless AdminService.is_admin?(current_user)
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end
end
