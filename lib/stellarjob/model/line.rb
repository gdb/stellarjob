class Stellarjob::Model::Line
  include MongoMapper::Document
  safe
  timestamps!

  set_collection_name 'lines'

  key :_id, String, default: lambda { 'line_' + Stellarjob::Util.random }
  key :account, String
  key :amount, Integer
  # key :active, Boolean

  def to_s
    "Line[#{_id}]<account=#{account.inspect} amount=#{amount.inspect}>"
  end

  def self.processed?(account, limit)
    self.first(account: account, amount: limit)
  end

  def self.processed!(account, limit)
    self.create(account: account, amount: limit)
  end
end
