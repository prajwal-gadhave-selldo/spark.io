class Comment < ApplicationRecord
  # Validations
  validates :content, :user_id, :blog_id, presence: true
  # validates :user_id, uniqueness: { scope: :blog_id }


  # Associations
  belongs_to :user
  belongs_to :blog

  # Callbacks
end
