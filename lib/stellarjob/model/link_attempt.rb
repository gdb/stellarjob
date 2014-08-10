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

  def fulfill!(account)
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

    Stellarjob::Twitter.bot.tweet("@#{twitter_username}: Sent you #{pending_points} +++: https://www.stellar.org/viewer/#live/#{account}")

    self.active = false
    self.save!
  end
end
