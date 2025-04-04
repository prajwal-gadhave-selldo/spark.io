class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token


  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  private

  def authenticate_user
    token = cookies.signed[:jwt] ? cookies.signed[:jwt] : cookies[:jwt]
    begin
      decoded_token = JWT.decode(token, "tempjwtsalt")[0] # Rails.application.credentials.secret_key_base``
      @current_user = User.find(decoded_token["id"])

    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError, ActiveRecord::RecordNotFound => e
      # head :unauthorized
      # redirect_to login_path unless request.original_fullpath == login_path or request.original_fullpath == signup_path
      redirect_to login_path, alert: "Please login first." unless [ login_path, signup_path ].include?(request.original_fullpath)
    end
  end

  def current_user
    @current_user ||= authenticate_user
  end

  def logged_in
    redirect_to root_path if current_user.present?
  end
end
