class AdCodesController < ApplicationController
  before_action :set_campaign
  breadcrumb -> { @campaign.name }, :current
  breadcrumb 'Ad codes', -> { campaign_ad_codes_path(@campaign) }, match: :exclusive

  def index
    @ad_codes = @campaign.ad_code_value_summaries
                         .group_by(&:name)
  end

  def show
    @ad_code = AdCode.where(campaign_id: @campaign.id, index: params[:id]).first
    @other_ad_codes = AdCode.where('ad_codes.campaign_id = ? AND ad_codes.index <> ?', @campaign.id, @ad_code.index).order(quality: :desc)
    @values = UtmCampaignValue.between(@ad_code.index, start, finish)

    breadcrumb @ad_code.full_name, request.path
  end

  def against
    @ad_code1 = AdCode.where(campaign: @campaign, index: params[:ad_code_id]).first
    @ad_code2 = AdCode.where(campaign: @campaign, index: params[:other_index]).first

    @table = UtmCampaignValue::ContingencyTable.new(@ad_code1.index, @ad_code2.index)

    breadcrumb @ad_code1.full_name, campaign_ad_code_path(@campaign, params[:ad_code_id]), match: :exclusive
    breadcrumb "against / #{@ad_code2.full_name}", request.path
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
