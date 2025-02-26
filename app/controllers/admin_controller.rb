require 'csv'

class AdminController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_user, only: [ :show_user, :edit_user, :update_user, :user_activity ]
  layout "admin"

  def users
    @users = User.all.order(created_at: :desc)

     # Apply filters if present
     @users = @users.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
     @users = @users.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
     
     @users = @users.where(role: params[:role]) if params[:role].present?
     @users = @users.where(status: params[:status]) if params[:status].present?
     
     # Filter by joined date
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
     
     # Handle search query
     if params[:search].present?
       @users = @users.where("name ILIKE :query OR email ILIKE :query", query: "%#{params[:search]}%")
     end
     
     # Final order
     @users = @users.order(created_at: :desc)
     
     # Add CSV export functionality
     respond_to do |format|
       format.html
       format.csv { send_data generate_csv(@users), filename: "users-#{Date.today}.csv" }
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end

  def authorize_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end

  def generate_csv(users)
    
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

end
