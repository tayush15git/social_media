class TweetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet, only: [:edit, :update, :destroy, :publish_now]

  def index
    @tweets = current_user.tweets.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweets_list", partial: "tweets/list", locals: { tweets: @tweets }) }
    end
  end

  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = current_user.tweets.build(tweet_params)

    if @tweet.save
      if @tweet.scheduled_at.present?
        # Schedule the tweet using ActiveJob (Delayed Job or Sidekiq)
        ScheduleTweetJob.set(wait_until: @tweet.scheduled_at).perform_later(@tweet.id)
        flash[:notice] = "Tweet scheduled for #{@tweet.scheduled_at.strftime('%B %d, %I:%M %p')}"
      else
        # Post immediately
        if TwitterClient.new.post_tweet(@tweet.content)  # ✅ Ensure TwitterClient is instantiated
          @tweet.update(published: true)
          flash[:notice] = "Tweet posted successfully!"
        else
          flash[:alert] = "Failed to post tweet."
        end
      end
    else
      flash[:alert] = "Failed to create tweet."
    end

    redirect_to tweets_path
  end

  def publish_now
    if @tweet && TwitterClient.new.post_tweet(@tweet.content)  # ✅ Check if @tweet exists
      @tweet.update(published: true)
      redirect_to tweets_path, notice: "Tweet posted successfully!"
    else
      redirect_to tweets_path, alert: "Failed to post tweet."
    end
  end

  def edit
    redirect_to tweets_path, alert: "Tweet not found." if @tweet.nil?
  end

def update
  @tweet = current_user.tweets.find_by(id: params[:id])

  if @tweet.nil?
    redirect_to tweets_path, alert: "Tweet not found."
    return
  end

  if @tweet.update(tweet_params)
    respond_to do |format|
      format.html { redirect_to tweets_path, notice: "Tweet updated successfully!" }
      format.turbo_stream { redirect_to tweets_path }
    end

  else
    render :edit, status: :unprocessable_entity
  end
end



  def destroy
    if @tweet
      @tweet.destroy
      redirect_to tweets_path, notice: "Tweet deleted successfully!"
    else
      redirect_to tweets_path, alert: "Tweet not found."
    end
  end

  private

  def set_tweet
    @tweet = current_user.tweets.find_by(id: params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:content, :scheduled_at)
  end

  def authenticate_user!
    redirect_to root_path, alert: "You must be signed in!" unless session[:user_id]
  end
end
