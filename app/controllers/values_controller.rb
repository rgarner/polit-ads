class ValuesController < ApplicationController
  breadcrumb 'Donald J. Trump', :current
  breadcrumb 'Ad codes', -> { campaign_ad_codes_path(campaign_id: 'trump') }, match: :exclusive

  def show
    @value = AdCodeValueSummary.joins(:campaign).find_by!(
      'campaigns.slug' => params[:campaign_id],
      index: params[:ad_code_id],
      value: params[:id]
    )

    @values = AdCodeValueSummary.between(
      @value.index,
      @value.value,
      start,
      finish
    )

    breadcrumb @value.name, request.path # no AdCode path at time of writing
    breadcrumb @value.value, request.path
  end

  def start
    @start ||= params[:start] ? Date.parse(params[:start]) : Date.today - 30
  end

  def finish
    @finish ||= params[:end] ? Date.parse(params[:end]) : Date.today
  end
end
