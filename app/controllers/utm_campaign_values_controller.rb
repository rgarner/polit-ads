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
    ).where(index: @index).group(:value).order(count: :desc).to_a

    breadcrumb "utm#{@index}", utm_campaign_value_path(@index)
  end

  def against
    @index1 = params[:utm_campaign_value_id]
    @index2 = params[:other_id]

    @table = UtmCampaignValue::ContingencyTable.new(@index1, @index2)

    breadcrumb "utm#{@index1}", utm_campaign_value_path(@index1), match: :exclusive
    breadcrumb "against / utm#{@index2}", request.path
  end

  def between
    @index = params[:utm_campaign_value_id]

    @start = Date.parse(between_params[:start])
    @finish = Date.parse(between_params[:end])

    @values = UtmCampaignValue.between(@index, @start, @finish)

    breadcrumb "utm#{@index}", utm_campaign_value_path(@index), match: :exclusive
    breadcrumb "between #{@start} and #{@finish}", request.path
  end

  def hosts
    @index = params[:utm_campaign_value_id]

    rows = UtmCampaignValue.select('utm_campaign_values.value, hosts.hostname, hosts.purpose, COUNT(*)')
                           .where(index: @index)
                           .joins(advert: :host)
                           .group('utm_campaign_values.value, hosts.id')
                           .order(count: :desc)

    @table = Host::ContingencyTable.new(rows)

    breadcrumb "utm#{@index}", utm_campaign_value_path(@index), match: :exact
    breadcrumb 'Hosts', request.path
  end

  private

  def between_params
    %i[utm_campaign_value_id start end].each { |p| raise ActionController::ParameterMissing, p unless params[p] }
    params.slice(:start, :end)
  end
end
