class UtmCampaignValuesController < ApplicationController
  breadcrumb 'UTM Campaign Values', :utm_campaign_values_path, match: :exclusive

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

    breadcrumb "utm#{@index}", utm_campaign_value_path(@index)
  end

  def against
    @index1 = params[:utm_campaign_value_id]
    @index2 = params[:other_id]

    @table = UtmCampaignValue::ContingencyTable.new(@index1, @index2)

    breadcrumb "utm#{@index1}", utm_campaign_value_path(@index1), match: :exclusive
    breadcrumb "against / utm#{@index2}", request.path
  end
end
