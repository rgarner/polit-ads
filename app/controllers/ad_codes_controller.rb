class AdCodesController < ApplicationController
  before_action :set_campaign
  before_action :set_ad_code, except: :index

  breadcrumb -> { @campaign.name }, :current
  breadcrumb 'Ad codes', -> { campaign_ad_codes_path(@campaign) }, match: :exclusive

  def index
    @ad_codes = ad_codes_with_sort.group_by(&:name)
  end

  def show
    @ad_codes = ad_codes_with_sort.where(campaign_id: @campaign.id, index: params[:id])
    breadcrumb @ad_code.full_name, request.path
  end

  DENSITY_ROWHEIGHTS = {
    'dense' => 32,
    'spacious' => 42
  }.freeze

  def timeline
    @values = AdCodeValueUsage.between(@campaign, @ad_code.index, start, finish, dimension: dimension)
    @options = {
      rowHeight: DENSITY_ROWHEIGHTS[params[:density] || 'spacious'],
      svgClass: "utm#{@ad_code.index}"
    }

    breadcrumb "#{@ad_code.full_name} / Timeline", request.path
  end

  def against
    @ad_code2 = AdCode.where(campaign: @campaign, index: params[:other_index]).first

    @table = AdCodeValueUsage::ContingencyTable.new(@campaign.id, @ad_code.index, @ad_code2.index)

    breadcrumb @ad_code.full_name, campaign_ad_code_path(@campaign, params[:ad_code_id]), match: :exclusive
    breadcrumb "against / #{@ad_code2.full_name}", request.path
  end

  def hosts
    @table = Host::ContingencyTable.new(AdCodeValueUsage.by_host(@campaign.id, @ad_code.index))

    breadcrumb @ad_code.full_name, campaign_ad_code_path(campaign_id: @campaign.slug, id: @ad_code.index), match: :exclusive
    breadcrumb 'Hosts', request.path
  end

  private

  def ad_codes_with_sort
    ad_codes = @campaign.ad_code_value_summaries.with_value_names
    if params[:sort] == 'spend'
      ad_codes.order('COALESCE(approximate_spend, 0) DESC')
    else
      ad_codes.order(count: :desc)
    end
  end

  def set_ad_code
    @ad_code = AdCode.where(campaign: @campaign, index: params[:ad_code_id] || params[:id]).first
    @other_ad_codes = AdCode.where('ad_codes.campaign_id = ? AND ad_codes.index <> ?', @campaign.id, @ad_code.index).order(quality: :desc)
  end

  def set_campaign
    @campaign ||= Campaign.where(slug: params[:campaign_id]).first
  end

  def start
    @start ||= params[:start] ? Date.parse(params[:start]) : Date.today - 30
  end

  def finish
    @finish ||= params[:end] ? Date.parse(params[:end]) : Date.today
  end

  def dimension
    params[:dimension].presence || 'count'
  end
end
