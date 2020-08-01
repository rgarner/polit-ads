class AdvertsController < ApplicationController
  def show
    @advert = Advert.find(params[:id])
  end

  def by_utm_value
    @value = UtmCampaignValue.where(value: params[:utm_value]).first
    @adverts = Advert
               .joins(:utm_campaign_values)
               .where('utm_campaign_values.value = ?', params[:utm_value])
               .order(ad_creation_time: :desc)
               .page(params[:page])
  end

  def with_utm_values
    @adverts = Advert.with_utm_values(**utm_value_params).page(params[:page])
  end

  private

  def utm_value_params
    @utm_value_params ||= (0..22).each_with_object({}) do |n, result|
      key = "utm#{n}"
      result[key.to_sym] = params[key] if params[key]
    end
  end
end

