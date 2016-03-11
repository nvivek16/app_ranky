require_relative 'source'
require_relative 'db_connector'

class RankScrapper

	def initialize
		@read_only_client = DbConnector.new("development").client
		@client = DbConnector.new("development").client
	end

	def scrap
		populate_master_collections
		populate_category_collections
		download_source_and_insert
	end

	def populate_master_collections
		@collection_list = @read_only_client.query("select id, collection_name from collection_master order by id asc")
	end

	def populate_category_collections
		@category_list = @read_only_client.query("select id, category_name from category_master order by id asc")
	end

	def download_source_and_insert
		@collection_list.each do |collection|
			@category_list.each do |category|
				source = Source.new("IN", collection["collection_name"], category["category_name"])
				source.download
				source.each do |app_rank|
					@client.query("insert into app_monitor(`app_store_id`, `country_id`, `collection_id`, `category_id`, `rank`, `rating`, `created_at`) VALUES ('#{app_rank.app_store_id}', 1, #{collection['id']}, #{category['id']}, #{app_rank.rank}, #{app_rank.rating.to_f}, '#{app_rank.date}')");
				end
			end
		end
	end
end