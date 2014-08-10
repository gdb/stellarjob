class Stellarjob::Model::LinkAttempt
  include MongoMapper::Document
  safe
  timestamps!

  set_collection_name 'linkattempts'

  key :_id, String, default: lambda { 'link_' + Stellarjob::Util.random }
  key :twitter_username, String
  key :link_amount, Integer
  key :active, Boolean, default: true
  key :link_id, Integer
  key :pending_points, Integer, default: 1
  key :parent_tweet_id, Integer
  # Need to set class name here
  # one :user

  def to_s
    "LinkAttempt[#{_id}]<twitter_username=#{twitter_username.inspect}>"
  end

  def self.generate(opts)
    link_id = Stellarjob::Model::Counter.increment!('link_id')

    self.create(
      opts.merge(
        link_amount: 10000 + link_id,
        link_id: link_id
        )
      )
  end

  def prepare(account)
    puts "Found appropriate trustline, so preparing to link #{self} with #{account}"
   
    if stellar_username = Stellarjob::Stellar.account_to_username(account)
      display = "#{stellar_username} (#{account})"
    else
      display = account
    end

    tweet = Stellarjob::Twitter.tweet_reliably("@#{twitter_username}: Is your Stellar account #{display}? Reply 'yes' or ignore.")

    Stellarjob::Model::LinkAttemptTweet.create(
      twitter_username: twitter_username,
      link_attempt: self._id,
      stellar_account: account,
      tweet_id: tweet.id
      )
  end

  def fulfill!(tweet_id, account)
    puts "Fulfilling #{self} with #{account}"

    begin
      user = Stellarjob::Model::User.create(
        twitter_username: twitter_username,
        stellar_account: account,
        link_attempt: self._id
        )
    rescue Mongo::OperationFailure => e
      raise unless e.error_code == 11000

      puts "Loading existing user (recovering from breakage)"
      user = Stellarjob::Model::User.first(link_attempt: self._id)
    end

    user.send_points!(pending_points)

    puts "Tweeting about the fulfillment"
    Stellarjob::Twitter.tweet_reliably("@#{twitter_username}: Sent you #{pending_points} +++: https://www.stellar.org/viewer/#live/#{account}", in_reply_to_tweet_id: tweet_id)

    self.active = false
    self.save!
  end

  def link_attempt_tweets
    Stellarjob::Model::LinkAttemptTweet.all(active: true, link_attempt: self._id)
  end
end
