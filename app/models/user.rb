class User < ApplicationRecord

    # validations
    validates :name, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please Enter Valid Email Address" }, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }
    validates :role, presence: true, inclusion: { in: %w[admin user] }

    enum role: { admin: 0, user: 1 }
    

    # associations
    has_many :blogs
    has_many :comments
    has_many :likes
    
    # callbacks
end