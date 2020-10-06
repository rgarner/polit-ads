class AdCodeDailySummary < ApplicationRecord
  include ChartkickGrouping

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  ##
  # Return a list of hashes (only one!) in a form required by Chartkick,
  # e.g. { name: 'djt', data: { '2020-08-04' => 43, '2020-08-05' => 17 }  }
  def self.between(index, value, start, finish, dimension: 'count')
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      BETWEEN_SQL, 'sql', [[nil, start], [nil, finish], [nil, index], [nil, value]]
    )

    group_for_chartkick(result, dimension: dimension)
  end

  BETWEEN_SQL =
    <<~SQL.freeze
      SELECT start, count, approximate_spend
      FROM ad_code_daily_summaries
      WHERE start BETWEEN $1 AND $2
      AND index = $3 AND value = $4
    SQL
end
