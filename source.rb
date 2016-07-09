require 'market_bot'
require_relative 'app_rank'

class Source

  include Enumerable
  attr_accessor :country_code, :collection_name, :category_name

  def initialize(country_code, collection_name, category_name)
    self.country_code = country_code
    self.collection_name = collection_name
    self.category_name = category_name
    @app_ranks = []
    initialize_source
  end

  def initialize_source
    @source = MarketBot::Android::Leaderboard.new(collection_name, category_name)
  end

  def download_source
    @source.update(:country => country_code)
  end

  def download
    download_source
    transform_source
  end

  def transform_source
    @source.results.each.with_index(1) do |result, rank|
      @app_ranks << AppRank.new(result[:market_id], rank, result[:stars], country_code, Time.now.strftime("%F"))
    end
  end

  def each
    @app_ranks.each do |app_rank|
      yield app_rank
    end
  end
end
