class CreateHostDailySummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :host_daily_summaries, materialized: true
  end
end
