require 'twitter'

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_KEY']
      config.consumer_secret     = ENV['TWITTER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end

  def post_tweet(content)
    @client.update(content)
    true
  rescue Twitter::Error => e
    Rails.logger.error "[Twitter API Error] #{e.class}: #{e.message}"
    false
  end
end
