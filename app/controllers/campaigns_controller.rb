class CampaignsController < ApplicationController
  ADS_SINCE = '2020-07-22'.freeze

  def index
    @ads_since = ADS_SINCE
    @campaigns = Campaign.with_summaries.since(@ads_since)
    @ad_counts = Campaign.summary_graph_data
    @funding_entity_count = FundingEntity.count
  end
end
