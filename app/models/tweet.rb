class Tweet < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 280 }
  validates :scheduled_at, allow_nil: true, comparison: { greater_than: Time.current }

  scope :pending, -> { where(published: false).where.not(scheduled_at: nil) }
end
