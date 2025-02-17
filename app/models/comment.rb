class Comment < ApplicationRecord

  # Validations
  validates :content, :user_id, :blog_id, presence: true


  # Associations
  belongs_to :user
  belongs_to :blog

  # Callbacks
end
