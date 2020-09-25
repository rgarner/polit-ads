class CreateValueDailySummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :value_daily_summaries, materialized: true
  end
end
