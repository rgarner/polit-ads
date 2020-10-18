class WantsDailySummary < ApplicationRecord
  include ChartkickGrouping

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  ##
  # Daily, for campaign
  def self.daily(slug)
    group_for_chartkick(WantsDailySummary.where(slug: slug), by: 'wants_key')
  end

  ##
  # Weekly, for campaign
  def self.weekly(slug)
    weeks = WantsDailySummary.where(slug: slug)
            .select("extract('week' from start) AS start, wants_key, count, approximate_spend")
            .order('wants_key')
    group_for_chartkick(weeks, by: 'wants_key')
  end

  ##
  # Monthly, for campaign
  def self.monthly(slug)
    weeks = WantsDailySummary.where(slug: slug)
            .select("extract('month' from start) AS start, wants_key, count, approximate_spend")
            .order('start, wants_key')
    group_for_chartkick(weeks, by: 'wants_key')
  end
end
