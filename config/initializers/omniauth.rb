OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.allowed_request_methods = [:get, :post]
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end

