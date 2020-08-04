class UtmCampaignValuesController < ApplicationController
  def index
    @values = UtmCampaignValue.select('utm_campaign_values.index, utm_campaign_values.value, COUNT(*) AS count')
                              .group(:index, :value)
                              .order(:index, :value)
    @groups = @values.group_by(&:index)
  end

  def show
    @index = params[:id]

    # Low count; using .to_a means we'll incur one SELECT now instead of two with count
    @values = UtmCampaignValue.select(
      'utm_campaign_values.value, COUNT(*) AS count'
    ).where(index: @index).group(:value).to_a
  end

  def against
    @table = UtmCampaignValue::ContingencyTable.new(
      params[:utm_campaign_value_id],
      params[:other_id]
    )
  end
end
