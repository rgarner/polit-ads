class AdvertsController < ApplicationController
  breadcrumb 'UTM Campaign Values', :utm_campaign_values_path, match: :exclusive, except: :show

  def show
    @advert = Advert.find(params[:id])
    breadcrumb 'Advert', request.path
  end

  def by_utm_value
    @value = UtmCampaignValue.where(value: params[:utm_value]).first
    base_scope = Advert
                 .joins(:utm_campaign_values)
                 .where('utm_campaign_values.value = ?', params[:utm_value])
    @adverts = base_scope.order(ad_creation_time: :desc).page(params[:page])
    @min_max = base_scope.select('MIN(ad_creation_time) AS min, MAX(ad_creation_time) AS max')[0]

    breadcrumb "#{@value} / adverts", request.path
  end

  def with_utm_values
    @adverts = Advert.with_utm_values(**utm_value_params).page(params[:page])

    index1, index2 = utm_value_params.keys.map { |k| k.to_s.sub('utm', '') }

    breadcrumb "utm#{index1} against utm#{index2}",
      utm_campaign_value_against_path(utm_campaign_value_id: index1, other_id: index2)
    breadcrumb "adverts", request.path
  end

  private

  def utm_value_params
    @utm_value_params ||= (0..22).each_with_object(ActiveSupport::OrderedHash.new) do |n, result|
      key = "utm#{n}"
      result[key.to_sym] = params[key] if params[key]
    end
  end
end

