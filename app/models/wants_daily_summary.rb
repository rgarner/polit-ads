class WantsDailySummary < ApplicationRecord
  include ChartkickGrouping

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  WANTS_TO_COLOR = {
    'data' => '#3366cc',
    'money' => '#dc3912',
    'you_to_buy' => '#990099',
    'you_to_vote' => '#0099c6',
    'you_to_be_deterred' => '#109618',
    'you_to_attend' => '#3b3eac',
    'you_to_install_an_app' => 'silver',
    'to_persuade_you' => '#ff9900',
    'you_to_volunteer' => '#52c793'
  }.freeze

  ##
  # Daily, for campaign
  def self.daily(slug, dimension: 'count')
    days = WantsDailySummary.where(slug: slug).order(:start)

    group_by_want_color(days, dimension)
  end

  ##
  # Weekly, for campaign
  def self.weekly(slug, dimension: 'count')
    weeks = ActiveRecord::Base.connection.exec_query(
      WEEKLY_SQL, 'sql', [[nil, slug]]
    )

    group_by_want_color(weeks, dimension)
  end

  ##
  # Monthly, for campaign
  def self.monthly(slug, dimension: 'count')
    months = ActiveRecord::Base.connection.exec_query(
      MONTHLY_SQL, 'sql', [[nil, slug]]
    )

    group_by_want_color(months, dimension)
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

  def self.group_by_want_color(weeks, dimension)
    group_for_chartkick(weeks, by: 'wants_key', dimension: dimension) do |item|
      wants_key = item[:name]
      item[:color] = WANTS_TO_COLOR[wants_key]
    end
  end
end
