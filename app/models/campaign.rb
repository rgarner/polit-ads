class Campaign < ApplicationRecord
  has_many :funding_entities

  scope :with_summaries, lambda {
    select('campaigns.*, COUNT(*) AS ad_count, MIN(adverts.ad_creation_time) AS ad_oldest')
      .joins(funding_entities: :adverts)
      .group(:id)
  }

  scope :since, ->(date) { where('adverts.ad_creation_time > ?', date) }

  def self.summary_graph_data(date = Date.today)
    sql = <<~SQL
      SELECT campaigns.name, days.start::date, COUNT(*)
      FROM (select start, start + '23 hours 59 minutes 59 seconds' AS end
            from generate_series(
                         '2020-07-01'::timestamptz,
                         $1::timestamptz, '1 day'
                     ) AS start
           ) AS days
               JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
               JOIN funding_entities ON funding_entities.id = adverts.funding_entity_id
               JOIN campaigns ON campaigns.id = funding_entities.campaign_id
      GROUP BY days.start, campaigns.name
      ORDER BY campaigns.name DESC
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql, 'sql', [[nil, date.strftime('%Y-%m-%d')]]
    )

    # Map e.g
    # [
    #   {"value"=>"cm", "start"=>"2020-08-03", "count"=>122},
    #   {"value"=>"cm", "start"=>"2020-08-04", "count"=>1420},
    # ]
    # to
    # { name: 'cm', data: [['2020-08-03', 122], ['2020-08-04', 1420]] }

    result.group_by { |row| row['name'] }
          .each_with_object([]) do |(series, values), list|
      list << {
        name: series,
        data: values.map { |value| [value['start'], value['count']] }
      }
    end
  end
end
