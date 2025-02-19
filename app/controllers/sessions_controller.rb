class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:user][:email])

    binding.pry
    
    if user&.authenticate(params[:user][:password])
      token = user.generate_jwt
      binding.pry
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now
      }
      render json: { user: { id: user.id, email: user.email, name: user.name, token: token } }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    cookies.delete(:jwt)
    head :no_content
  end
end
