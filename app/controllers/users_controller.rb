class UsersController < ApplicationController
  before_action :authenticate_user, except: [ :create, :new ]

  def new
   @user = User.new
   render layout: 'auth'
  end

  def create
    user = User.new(user_params)

    if user.save
      token = user.generate_jwt
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now
      }
      # render json: { user: { id: user.id, email: user.email, name: user.name, token: token } }, status: :created
      redirect_to dashboard_path, notice: 'Successfully signed up!'

    else
      # render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      render :new, layout: 'auth', status: :unprocessable_entity
    end
  end

  def dashboard
    render layout: 'application'
  end

  def me
    render json: { user: { id: current_user.id, email: current_user.email, name: current_user.name } }
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
