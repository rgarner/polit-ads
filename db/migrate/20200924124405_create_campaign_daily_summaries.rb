class CreateCampaignDailySummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :campaign_daily_summaries, materialized: true
  end
end
