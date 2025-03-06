class TweetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = current_user.tweets.build(tweet_params)

    if @tweet.save
      redirect_to tweets_path, notice: "Tweet scheduled successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:content, :scheduled_at)
  end

  def authenticate_user!
    redirect_to root_path, alert: "You must be signed in!" unless session[:user_id]
  end
end
