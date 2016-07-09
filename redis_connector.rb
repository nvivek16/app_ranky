require 'redis'
require 'yaml'

class RedisConnector

  attr_accessor :client

  def initialize(env)
    @redis_settings = YAML.load_file(File.dirname(__FILE__) + "/redis.yml")[env]
    self.client = Redis.new(@redis_settings)
  end
end
