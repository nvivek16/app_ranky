require 'mysql2'
require 'yaml'

class DbConnector

  attr_accessor :client

  def initialize(env)
    @db_settings = YAML.load_file(File.dirname(__FILE__) + "/database.yml")[env]
    self.client = Mysql2::Client.new(@db_settings)
  end
end
