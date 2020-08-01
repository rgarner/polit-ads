class UtmCampaignValuesController < ApplicationController
  def index
    @values = UtmCampaignValue.select('utm_campaign_values.index, utm_campaign_values.value, COUNT(*) AS count')
                              .group(:index, :value)
                              .order(:index, :value)
    @groups = @values.group_by(&:index)
    logger.warn(@groups)
  end

  def show
    @index = params[:id]
    @values = UtmCampaignValue.select('utm_campaign_values.value, COUNT(*) AS count').where(index: @index).group(:value)
  end

  def against
    @table = UtmCampaignValue::ContingencyTable.new(
      params[:utm_campaign_value_id],
      params[:other_id]
    )
  end
end
