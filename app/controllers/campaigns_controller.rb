class CampaignsController < ApplicationController
  ADS_SINCE = '2020-07-01'.freeze

  def index
    @ads_since = Date.parse(ADS_SINCE)
    @campaigns = Campaign.with_summaries.order(:id)
    @ad_counts = Campaign.summary_graph_data(from: @ads_since, dimension: dimension)
    @funding_entity_count = FundingEntity.count
  end

  def show
    @campaign = Campaign.find_by!(slug: params[:id])
    @dimension = dimension
    @wants_summary = WantsDailySummary.send(range, params[:id], dimension: dimension)

    breadcrumb @campaign.name, :current
  end

  private

  def range
    if CampaignsHelper::CAMPAIGN_RANGES.include?(params[:range])
      params[:range]
    else
      'weekly'
    end
  end

  def dimension
    params[:dimension].presence || 'count'
  end
end
