class WantsDailySummary < ApplicationRecord
  include ChartkickGrouping

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  ##
  # Daily, for campaign
  def self.daily(slug, dimension: 'count')
    days = WantsDailySummary.where(slug: slug).order(:start)

    group_for_chartkick(days, by: 'wants_key', dimension: dimension)
  end

  ##
  # Weekly, for campaign
  def self.weekly(slug, dimension: 'count')
    weeks = ActiveRecord::Base.connection.exec_query(
      WEEKLY_SQL, 'sql', [[nil, slug]]
    )

    group_for_chartkick(weeks, by: 'wants_key', dimension: dimension)
  end

  ##
  # Monthly, for campaign
  def self.monthly(slug, dimension: 'count')
    months = ActiveRecord::Base.connection.exec_query(
      MONTHLY_SQL, 'sql', [[nil, slug]]
    )
    group_for_chartkick(months, by: 'wants_key', dimension: dimension)
  end

  WEEKLY_SQL = <<~SQL.freeze
    SELECT extract('week' from start) AS start, wants_key,
      SUM(count) AS count, SUM(approximate_spend) AS approximate_spend,
      ROUND((COUNT(*) / SUM(COUNT(*)) OVER w_week) * 100, 2) AS percentage
    FROM wants_daily_summaries
    WHERE slug = $1 AND wants_key IS NOT NULL
    GROUP BY extract('week' from start), wants_key
    WINDOW
      w_week AS (PARTITION BY extract('week' from start))
    ORDER BY start, wants_key
  SQL

  MONTHLY_SQL = <<~SQL.freeze
    SELECT extract('month' from start) AS start, wants_key,
      SUM(count) AS count, SUM(approximate_spend) AS approximate_spend,
      ROUND((COUNT(*) / SUM(COUNT(*)) OVER w_month) * 100, 2) AS percentage
    FROM wants_daily_summaries
    WHERE slug = $1 AND wants_key IS NOT NULL
    GROUP BY extract('month' from start), wants_key
    WINDOW
      w_month AS (PARTITION BY extract('month' from start))
    ORDER BY start, wants_key
  SQL
end
