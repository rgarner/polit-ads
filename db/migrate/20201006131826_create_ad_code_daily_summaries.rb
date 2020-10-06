class CreateAdCodeDailySummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :ad_code_daily_summaries, materialized: true
  end
end
