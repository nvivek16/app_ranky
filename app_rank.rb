class AppRank
	attr_accessor :app_store_id, :rank, :rating, :country_code, :date

	def initialize(app_store_id, rank, rating, country_code, date)
		self.app_store_id = app_store_id
		self.rank = rank
		self.rating = rating
		self.country_code = country_code
		self.date = date
	end
end