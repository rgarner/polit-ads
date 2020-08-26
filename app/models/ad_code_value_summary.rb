class AdCodeValueSummary < ApplicationRecord
  include ChartkickGrouping

  belongs_to :campaign

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  ##
  # Return a list of hashes (only one!) in a form required by Chartkick,
  # e.g. { name: 'djt', data: { '2020-08-04' => 43, '2020-08-05' => 17 }  }
  def self.between(index, value, start, finish)
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      BETWEEN_SQL, 'sql', [[nil, start], [nil, finish], [nil, index], [nil, value]]
    )

    group_for_chartkick(result)
  end

  BETWEEN_SQL =
    <<~SQL.freeze
      SELECT days.start::date, COUNT(*)
      FROM (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
            FROM generate_series(
                         $1::timestamptz,
                         $2::timestamptz, '1 day'
                     ) AS start
           ) AS days
               JOIN adverts ON
                 adverts.ad_creation_time BETWEEN days.start AND days.end AND
                 adverts.utm_values @> ('{ "' || $3 || '": "' || $4 || '"}')::jsonb
      GROUP BY days.start
      ORDER BY COUNT(*) DESC, days.start
    SQL
end
