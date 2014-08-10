module Stellarjob::Config
  def self.config
    @config ||= YAML.load_file(File.expand_path('../../../stellarjob.yml', __FILE__))
  end
end
