class Campaign < ApplicationRecord
  include ChartkickGrouping

  has_many :funding_entities
  has_many :hosts
  has_many :ad_codes
  has_many :ad_code_value_summaries # Materialized view model
  has_many :campaign_daily_summaries

  scope :with_summaries, lambda {
    select('campaigns.*, SUM(count) AS ad_count, MIN(campaign_daily_summaries.start) AS ad_oldest')
      .joins(:campaign_daily_summaries)
      .group(:id)
  }

  scope :since, ->(date) { where('campaign_daily_summaries.start > ?', date) }

  def to_param
    slug
  end

  def surname
    slug.capitalize
  end

  def self.summary_graph_data(from:, to: Date.today, dimension: 'count')
    sql = <<~SQL
      SELECT * FROM campaign_daily_summaries WHERE start BETWEEN $1 AND $2
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql, 'sql',
      [[nil, from.strftime('%Y-%m-%d')], [nil, to.strftime('%Y-%m-%d')]]
    )

    group_for_chartkick(result, by: 'name', dimension: dimension)
  end
end
