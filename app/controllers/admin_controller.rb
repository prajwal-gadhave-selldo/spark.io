require 'csv'

class AdminController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_user, only: [:show_user, :edit_user, :update_user, :user_activity]
  before_action :set_blog, only: [:show_blog, :edit_blog, :update_blog, :destroy_blog]
  layout "admin"

  def dashboard
    # Get counts for the dashboard cards
    @total_users = User.count
    @total_blogs = Blog.count
    @total_comments = Comment.count
    @total_likes = Like.count
    
    # Get new users in the last 30 days
    @new_users_count = User.where("created_at >= ?", 30.days.ago).count
    
    # Get data for user growth chart (last 12 months)
    @user_growth_data = 12.downto(0).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime("%b %Y"),
        count: User.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count
      }
    end

    @content_data = 12.downto(0).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime("%b %Y"),
        blogs: Blog.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count,
        comments: Comment.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count
      }
    end
    
    @latest_users = User.order(created_at: :desc).limit(5)
    
    @latest_blogs = Blog.includes(:user).order(created_at: :desc).limit(5)
  end
  
  def activity
    @date_range = params[:range] || "30_days"
    
    case @date_range
    when "7_days"
      @start_date = 7.days.ago
    when "30_days"
      @start_date = 30.days.ago
    when "90_days"
      @start_date = 90.days.ago
    when "year"
      @start_date = 1.year.ago
    else
      @start_date = 30.days.ago
    end
    

    # By GPT
    @daily_data = (@start_date.to_date..Date.today).map do |date|
      next_date = date + 1.day
      {
        date: date.strftime("%b %d"),
        users: User.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        blogs: Blog.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        comments: Comment.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        likes: Like.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count
      }
    end

    # By GPT
    @active_users = User
    .left_joins(:blogs, :comments, :likes)
    .where(
      "blogs.created_at >= :start_date OR 
       comments.created_at >= :start_date OR 
       likes.created_at >= :start_date OR 
       users.created_at >= :start_date", 
      start_date: @start_date
    )
    .select(
      "users.id, 
       users.name, 
       users.email, 
       COUNT(DISTINCT blogs.id) as blog_count, 
       COUNT(DISTINCT comments.id) as comment_count, 
       COUNT(DISTINCT likes.id) as like_count"
    )
    .group(:id, :name, :email)
    .order(Arel.sql("(COUNT(DISTINCT blogs.id) + COUNT(DISTINCT comments.id) + COUNT(DISTINCT likes.id)) DESC"))
    .limit(10)

    # By GPT
    @popular_blogs = Blog
    .left_joins(:comments, :likes)
    .select(
      "blogs.id, 
      blogs.title, 
      blogs.created_at, 
      COUNT(DISTINCT comments.id) as comment_count, 
      COUNT(DISTINCT likes.id) as like_count"
    )
    .where("blogs.created_at >= ?", @start_date)
    .group(:id, :title, :created_at)
    .order(Arel.sql("(COUNT(DISTINCT comments.id) + COUNT(DISTINCT likes.id)) DESC"))
    .limit(5)
  end

  def users
    @users = User.all.order(created_at: :desc)
    
    # Apply filters if present
    @users = @users.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    @users = @users.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.where(status: params[:status]) if params[:status].present?
    
    case params[:joined]
    when "7_days"
      @users = @users.where("created_at >= ?", 7.days.ago)
    when "month"
      @users = @users.where("created_at >= ?", 1.month.ago)
    when "3_months"
      @users = @users.where("created_at >= ?", 3.months.ago)
    when "year"
      @users = @users.where("created_at >= ?", 1.year.ago)
    end
    

    if params[:search].present?
      @users = @users.where("name ILIKE :query OR email ILIKE :query", query: "%#{params[:search]}%")
    end
    
    @users = @users.order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.csv { send_data generate_users_csv(@users), filename: "users-#{Date.today}.csv" }
    end
  end

  def show_user
  end

  def edit_user
  end

  def update_user
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      render :edit_user, status: :unprocessable_entity
    end
  end

  def user_activity
    @blogs = @user.blogs.order(created_at: :desc)
    @comments = @user.comments.includes(:blog).order(created_at: :desc)
    @likes = @user.likes.includes(:blog).order(created_at: :desc)
  end

  def blogs
    @blogs = Blog.includes(:user, :comments, :likes).order(created_at: :desc)
    
    # Apply filters if present
    
    @blogs = @blogs.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
    @blogs = @blogs.joins(:user).where("users.name ILIKE ?", "%#{params[:author]}%") if params[:author].present?
    
    @blogs = @blogs.where(category: params[:category]) if params[:category].present?
    @blogs = @blogs.where(status: params[:status]) if params[:status].present?
    
    
    case params[:date_range]
    when "7_days"
      @blogs = @blogs.where("blogs.created_at >= ?", 7.days.ago)
    when "month"
      @blogs = @blogs.where("blogs.created_at >= ?", 1.month.ago)
    when "3_months"
      @blogs = @blogs.where("blogs.created_at >= ?", 3.months.ago)
    when "year"
      @blogs = @blogs.where("blogs.created_at >= ?", 1.year.ago)
    end
    
    
    # Handle search query
    if params[:search].present?
      @blogs = @blogs.where("title ILIKE :query OR content ILIKE :query", query: "%#{params[:search]}%")
    end
    
    @blogs = @blogs.order(created_at: :desc)
    
    # Add CSV export functionality
    respond_to do |format|
      format.html
      format.csv { send_data generate_blogs_csv(@blogs), filename: "blogs-#{Date.today}.csv" }
    end
  end

  def show_blog
  end

  def new_blog
    @blog = Blog.new
  end

  def create_blog
    @blog = Blog.new(blog_params)
    @blog.user = current_user

    if @blog.save
      redirect_to admin_blogs_path, notice: "Blog was successfully created."
    else
      render :new_blog, status: :unprocessable_entity
    end
  end

  def edit_blog
  end

  def update_blog
    if @blog.update(blog_params)
      redirect_to admin_blog_path(@blog), notice: "Blog was successfully updated."
    else
      render :edit_blog, status: :unprocessable_entity
    end
  end

  def destroy_blog
    @blog.destroy
    redirect_to admin_blogs_path, notice: "Blog was successfully deleted."
  end

  private

  def set_user
    begin
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to admin_users_path, alert: "User not found."
    end
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :excerpt, :category, :status, :featured_image)
  end

  def authorize_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end

  def generate_users_csv(users)
    headers = ['ID', 'Name', 'Email', 'Role', 'Created At']
    
    CSV.generate(headers: true) do |csv|
      csv << headers
      
      users.each do |user|
        csv << [
          user.id,
          user.name,
          user.email,
          user.role,
          user.created_at.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end
    end
  end

  def generate_blogs_csv(blogs)
    headers = ['ID', 'Title', 'Author', 'Comments', 'Likes', 'Created At']
    
    CSV.generate(headers: true) do |csv|
      csv << headers
      
      blogs.each do |blog|
        csv << [
          blog.id,
          blog.title,
          blog.user.name,
          blog.comments.count,
          blog.likes.count,
          blog.created_at.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end
    end
  end
end