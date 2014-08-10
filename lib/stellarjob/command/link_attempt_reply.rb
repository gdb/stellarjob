class Stellarjob::Command::LinkAttemptReply
  def self.handle(*args)
    lar = self.new(*args)
    lar.run
  end

  def initialize(tweet, sender, in_reply_to_tweet_id)
    @tweet = tweet
    @sender = sender
    @in_reply_to_tweet_id = in_reply_to_tweet_id
  end

  def bot
    Stellarjob::Twitter.bot
  end

  def run
    puts "Processing link attempt acceptance"

    if link_attempt_tweet = Stellarjob::Model::LinkAttemptTweet.first(
        twitter_username: @sender,
        tweet_id: @in_reply_to_tweet_id,
        active: true
        )
      bot.favorite(@tweet)
      link_attempt_tweet.accept!(@tweet.id)
    else
      puts "Could not find an associated link attempt tweet"
    end
  end
end
