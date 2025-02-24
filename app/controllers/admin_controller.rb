class AdminController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin
  before_action :set_user, only: [:show_user, :edit_user, :update_user, :user_activity]
  layout 'admin'

  def users
    
    @users = User.all.order(created_at: :desc)
  end

  def show_user
  end

  def edit_user
  end

  def update_user
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
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
end