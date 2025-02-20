class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include Pundit::Authorization
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token

  private

  def authenticate_user
    token = cookies.signed[:jwt]
    begin
      decoded_token = JWT.decode(token, "tempjwtsalt")[0] # Rails.application.credentials.secret_key_base``
      @current_user = User.find(decoded_token["id"])
      
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      # head :unauthorized
      redirect_to login_path
    end

  end

  def current_user
    @current_user ||= authenticate_user
  end
end
