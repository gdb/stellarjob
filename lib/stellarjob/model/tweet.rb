class Stellarjob::Model::Tweet
  include MongoMapper::Document
  safe
  timestamps!

  set_collection_name 'tweets'

  key :_id, String, default: lambda { 'tweet_' + Stellarjob::Util.random }
  key :tweet_id, Integer
  key :sender, String
  key :text, String
end
