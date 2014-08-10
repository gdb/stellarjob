class Stellarjob::Model::User
  include MongoMapper::Document
  safe
  timestamps!

  set_collection_name 'users'

  key :_id, String, default: lambda { 'user_' + Stellarjob::Util.random }
  key :twitter_username, String
  key :stellar_account, String
  key :sent_amount, Integer, default: 0
  key :link_attempt, String

  def to_s
    "User[#{_id}]<twitter_username=#{twitter_username.inspect}>"
  end

  # belongs_to :link_attempt

  def send_points!(points)
    puts "Sending #{points} to #{stellar_account}"

    Stellarjob::Stellar.send_points(stellar_account, points)

    self.sent_amount += points
    self.save!
  end

  def total_from_network
    lines = Stellarjob::Stellar.account_lines(stellar_account)
    relevant = lines['result']['lines'].detect do |line|
      line['account'] == Stellarjob::Stellar.stellarjob_account_id &&
        line['currency'] == '+++'
    end

    relevant ? relevant.fetch('balance') : nil
  end
end
