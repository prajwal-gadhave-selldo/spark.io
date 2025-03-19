class UsersController < ApplicationController
  before_action :authenticate_user, except: [ :create, :new ]
  before_action :logged_in, only: [ :new, :create ]

  def new
   @user = User.new
   render layout: "auth"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      token = @user.generate_jwt
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now
      }
      # render json: { user: { id: user.id, email: user.email, name: user.name, token: token } }, status: :created
      redirect_to dashboard_path, notice: "Successfully signed up!"

    else
      # render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      render :new, layout: "auth", status: :unprocessable_entity
    end
  end

  def dashboard
    @blogs = Blog.includes(:user).order(created_at: :desc)
    render layout: "application"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
