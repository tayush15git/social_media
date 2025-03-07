class Tweet < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 280 }
  validates :scheduled_at, allow_nil: true, comparison: { greater_than: Time.current }

  scope :pending, -> { where(published: false).where.not(scheduled_at: nil) }

  after_create :publish_immediately, unless: :scheduled?

  def scheduled?
    scheduled_at.present?
  end

  def publish_to_twitter
    return if content.blank?

    begin
      TWITTER_CLIENT.update(content)
      update(published: true)  # Mark as published in the database
    rescue Twitter::Error => e
      Rails.logger.error "Failed to post to Twitter: #{e.message}"
    end
  end

  private

  def publish_immediately
    publish_to_twitter if scheduled_at.nil?
  end
end
