require_relative 'app_detail_scrapper'
require "byebug"
@read_only_client = DbConnector.new("development").client
apps = @read_only_client.query("select app_store_id from app")

apps.each do |app|
  AppDetailScrapper.new(app['app_store_id']).scrap
end
