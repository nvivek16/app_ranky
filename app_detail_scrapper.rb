require_relative 'app_detail'
require_relative 'db_connector'
require 'market_bot'
require 'byebug'

class AppDetailScrapper

	def initialize(app_name)
		@app_name = app_name
		@read_only_client = DbConnector.new("development").client
		@client = DbConnector.new("development").client
	end

	def scrap
		populate_category_mapping
		initialize_source
		download_source
		transform
		insert
	end

	private

	def populate_category_mapping
		unless AppDetail.category_mappings
			temp = @read_only_client.query("select id, category_name from category_master order by id asc")
			AppDetail.category_mappings = temp.reduce({}) do |mappings, i|
				mappings[i['category_name']] = i['id']
				mappings
			end
		end
	end

	def initialize_source
		@source = MarketBot::Android::App.new(@app_name)
	end

	def download_source
		@source.update()
	end

	def transform
		@app_detail = AppDetail.new(@source)
	end

	def insert
		#Find if already exists
		app_id = @client.query("select app_store_id from app where app_store_id = '#{@app_name}'").first
		if(app_id)
			update
		else
			@client.query("insert into app(`app_store_id`, `title`, `last_updated_at`, `current_version`, `category`, `installs`, `description`, `votes`, `banner_icon_url`, `email`, `developer`, `related_apps`, `last_scrapped_at`) VALUES ('#{@app_detail.app_store_id}', '#{@app_detail.title}', '#{@app_detail.last_updated_at.strftime('%F')}', '#{@app_detail.current_version}', '#{@app_detail.category}','#{@app_detail.installs}', '#{@app_detail.description}', '#{@app_detail.votes}', '#{@app_detail.banner_icon_url}', '#{@app_detail.email}', '#{@app_detail.developer}', '#{@app_detail.related_apps}', '#{Time.now.strftime('%F %H:%m:%S')}')");
		end
	end

	def update
		@client.query("
			update app set title = '#{@app_detail.title}',
			last_updated_at = '#{@app_detail.last_updated_at.strftime('%F')}',
			current_version = '#{@app_detail.current_version}',
			category = '#{@app_detail.category}',
			installs = '#{@app_detail.installs}',
			description = '#{@app_detail.description}',
			votes = '#{@app_detail.votes}',
			banner_icon_url = '#{@app_detail.banner_icon_url}',
			email = '#{@app_detail.email}',
			developer = '#{@app_detail.developer}',
			related_apps = '#{@app_detail.related_apps}',
			last_scrapped_at = '#{Time.now.strftime('%F %H:%m:%S')}'
			where app_store_id = '#{@app_detail.app_store_id}' limit 1
		")
	end
end