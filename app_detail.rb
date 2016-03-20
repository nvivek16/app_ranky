require "time"
require "byebug"
require 'cgi'
class AppDetail
	attr_accessor :app_store_id, :title, :last_updated_at, :current_version, :category,
	:installs, :description, :votes, :banner_icon_url, :email, :developer, :related_apps


	def initialize(source)
		self.app_store_id = source.app_id
		self.title = source.title
		self.last_updated_at = Time.parse(source.updated)
		self.current_version = source.current_version
		self.category = source.category && self.class.category_mappings[source.category.downcase] || 0
		self.installs = source.installs
		self.description = CGI.escapeHTML(source.description)
		self.votes = source.votes.to_i
		self.banner_icon_url = source.banner_icon_url
		self.email = source.email
		self.developer = source.developer
		self.related_apps = source.related.collect{|i| i[:app_id]}.join('~')
	end

	def self.category_mappings=(mappings)
		unless @category_mappings
			@category_mappings = mappings
		end
	end

	def self.category_mappings
		@category_mappings
	end
end