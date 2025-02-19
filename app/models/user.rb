class User < ApplicationRecord

  has_secure_password # by bcrypt 

  # validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please Enter Valid Email Address" }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :role, presence: true, inclusion: { in: %w[admin user] }

  def generate_jwt
    JWT.encode({
      id: id,
      email: email,
      exp: 24.hours.from_now.to_i
    }, "tempjwtsalt") # Rails.application.credentials.secret_key_base
  end
  
  # associations
  has_many :blogs
  has_many :comments
  has_many :likes
  
  # callbacks
end