class Like < ApplicationRecord
  # validations
  validates :user_id, presence: true, uniqueness: { scope: :blog_id }
  validates :blog_id, presence: true

  # associations
  belongs_to :user
  belongs_to :blog
end
