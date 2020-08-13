class AdCodesController < ApplicationController
  before_action :set_campaign

  def index
    @ad_codes = @campaign.ad_code_value_summaries
                         .group_by(&:name)

    breadcrumb @campaign.name, request.path
    breadcrumb 'Ad codes', campaign_ad_codes_path(@campaign)
  end

  def show
    @ad_code = AdCode.where(campaign_id: @campaign.id, index: params[:id]).first

    @values = UtmCampaignValue.between(@ad_code.index, start, finish)

    breadcrumb @campaign.name, request.path
    breadcrumb 'Ad codes', campaign_ad_codes_path(@campaign), match: :exclusive
    breadcrumb @ad_code.name, request.path
  end

  private
  
  def set_campaign
    @campaign ||= Campaign.where(slug: params[:campaign_id]).first
  end

  def start
    @start ||= params[:start] ? Date.parse(params[:start]) : Date.today - 30
  end

  def finish
    @finish ||= params[:end] ? Date.parse(params[:end]) : Date.today
  end
end
