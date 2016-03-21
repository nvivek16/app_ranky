require_relative "redis_connector"
require "eventmachine"
require_relative "app_detail_scrapper"

$redis_client = RedisConnector.new("development").client

def check_redis
	if(app = $redis_client.lpop("user.apps.list"))
		$redis_client.rpush("user.apps.processing", app)
		work = proc {
			begin
				puts "Calling app scrapper for #{app} from event loop"
				AppDetailScrapper.new(app).scrap
				$redis_client.lrem("user.apps.processing", 0, app)
				$redis_client.lpush("user.apps.processed", app)
			rescue Exception => e
				puts "Exception while processing #{app}", e
			end
		}
		callable = proc {
			EM.defer proc{
				puts "Job finished for #{app}"
			}
		}
		EM.defer work, callable
	end
	EM.next_tick {
		check_redis
	}
end

EM.run {
	Signal.trap("INT")  { EM.stop }
  	Signal.trap("TERM") { EM.stop }
	check_redis
}
