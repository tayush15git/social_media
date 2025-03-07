class TweetSchedulerJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(tweet_id)
    tweet = Tweet.find_by(id: tweet_id, published: false)
    return unless tweet

    if TwitterClient.post_tweet(tweet.content)
      tweet.update(published: true)
      Rails.logger.info "Tweet ID #{tweet.id} posted successfully."
    else
      Rails.logger.error "Failed to post Tweet ID #{tweet.id}. Retrying..."
      raise StandardError, "Twitter API request failed"
    end
  end
end
