class Campaign < ApplicationRecord
  include ChartkickGrouping

  has_many :funding_entities
  has_many :hosts
  has_many :ad_codes
  has_many :ad_code_value_summaries # Materialized view model

  scope :with_summaries, lambda {
    select('campaigns.*, COUNT(*) AS ad_count, MIN(adverts.ad_creation_time) AS ad_oldest')
      .joins(funding_entities: :adverts)
      .group(:id)
  }

  scope :since, ->(date) { where('adverts.ad_creation_time > ?', date) }

  def to_param
    slug
  end

  def self.summary_graph_data(date = Date.today)
    sql = <<~SQL
      SELECT campaigns.name, days.start::date, COUNT(*)
      FROM (select start, start + '23 hours 59 minutes 59 seconds' AS end
            from generate_series(
                         '2020-07-01'::timestamp,
                         $1::timestamp, '1 day'
                     ) AS start
           ) AS days
               JOIN adverts ON adverts.host_id IS NOT NULL AND adverts.ad_creation_time BETWEEN days.start AND days.end
               JOIN funding_entities ON funding_entities.id = adverts.funding_entity_id
               JOIN campaigns ON campaigns.id = funding_entities.campaign_id
      GROUP BY days.start, campaigns.name
      ORDER BY campaigns.name DESC
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql, 'sql', [[nil, date.strftime('%Y-%m-%d')]]
    )

    group_for_chartkick(result, by: 'name')
  end
end
