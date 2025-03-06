class TweetSchedulerJob < ApplicationJob
  queue_as :default

  def perform(tweet_id)
    tweet = Tweet.find_by(id: tweet_id, published: false)
    return unless tweet

    if TwitterClient.post_tweet(tweet.content)
      tweet.update(published: true)
    end
  end
end
