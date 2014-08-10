class Stellarjob::Model::Counter
  include MongoMapper::Document

  set_collection_name 'counters'

  key :_id, String, default: lambda { 'counter_' + Stellarjob::Util.random }
  key :name, String, unique: true
  key :value, Integer, default: 1

  def self.increment!(name)
    data = {
      query: {name: name},
      update: {:$inc => {value: 1}},
      upsert: true,
      new: true
    }
    incremented = self.collection.find_and_modify(data)
    incremented['value']
  end

  def self.next(name)
    self.first(name: name).value + 1
  end
end
