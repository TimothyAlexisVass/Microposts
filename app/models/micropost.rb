class Micropost < ApplicationRecord
  belongs_to :user # This implies that user_id needs to be present
  default_scope -> { order(created_at: :desc) }
  validates :content, presence: true, length: { maximum: 140 }
end
