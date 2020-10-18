class CreateWantsDailySummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :wants_daily_summaries, materialized: true
  end
end
