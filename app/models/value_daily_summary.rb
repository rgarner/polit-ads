class ValueDailySummary < ApplicationRecord
  include ChartkickGrouping

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  ##
  # Return a list of hashes in a form required by Chartkick,
  # e.g. { name: 'djt', data: { '2020-08-04' => 43, '2020-08-05' => 17 }  }
  def self.between(campaign, index, start, finish, dimension: 'count')
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      BETWEEN_SQL, 'sql', [[nil, start], [nil, finish], [nil, index], [nil, campaign.id]]
    )

    group_for_chartkick(result, dimension: dimension, include: %w[value_name campaign_slug index])
  end

  BETWEEN_SQL =
    <<~SQL.freeze
      SELECT value, value_name, campaign_slug,
             index, start, count, COALESCE(approximate_spend, 0)::bigint AS approximate_spend
      FROM value_daily_summaries
      WHERE start BETWEEN $1 AND $2
        AND index = $3 AND campaign_id = $4
      ORDER BY count DESC, start
    SQL
end
