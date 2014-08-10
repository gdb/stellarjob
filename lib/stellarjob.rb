require 'mongo_mapper'

module Stellarjob
  require_relative 'stellarjob/version'

  require_relative 'stellarjob/command'
  require_relative 'stellarjob/config'
  require_relative 'stellarjob/model'
  require_relative 'stellarjob/stellar'
  require_relative 'stellarjob/twitter'
  require_relative 'stellarjob/util'

  def self.init
    MongoMapper.database = 'stellarjob'
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :safe => true)
    Stellarjob::Model::User.ensure_index(:twitter_username, unique: true)
    Stellarjob::Model::LinkAttempt.ensure_index(:twitter_username, unique: true)
  end
end
