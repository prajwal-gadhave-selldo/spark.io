class Blog < ApplicationRecord
  # Validations
  validates :title, :content, :user_id, presence: true


  # Associations
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Callbacks

  def liked_by?(user)
    likes.exists?(user: user)
  end
end
