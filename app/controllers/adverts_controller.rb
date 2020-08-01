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
end
