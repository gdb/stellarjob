class Stellarjob::Model::LinkAttemptTweet
  include MongoMapper::Document
  safe
  timestamps!

  set_collection_name 'linkattempttweets'

  key :_id, String, default: lambda { 'lat_' + Stellarjob::Util.random }
  key :twitter_username, String
  key :link_attempt, String
  key :stellar_account, String
  key :tweet_id, Integer
  key :active, Boolean, default: true

  def accept!(tweet_id)
    puts "Accepting link attempt tweet #{self}"

    attempt = Stellarjob::Model::LinkAttempt.find(link_attempt)
    attempt.fulfill!(tweet_id, stellar_account)

    self.active = false
    self.save!
  end
end
