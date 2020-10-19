class UpdateWantsDailySummariesToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :wants_daily_summaries,
      version: 2,
      revert_to_version: 1,
      materialized: true
  end
end
