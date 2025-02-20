class SessionsController < ApplicationController
  layout "auth"

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = user.generate_jwt

      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now
      }
      # render json: { user: { id: user.id, email: user.email, name: user.name, token: token } }
      redirect_to dashboard_path, notice: "Successfully logged in!"
    else
      # render json: { error: "Invalid email or password" }, status: :unauthorized
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    cookies.delete(:jwt)
    # head :no_content
    redirect_to login_path, notice: "Successfully logged out!"
  end
end
