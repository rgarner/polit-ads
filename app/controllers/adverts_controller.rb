class AdvertsController < ApplicationController
  include AdvertsController::Breadcrumbs

  has_scope :with_utm_values, type: :hash
  has_scope :hostname

  def index
    @adverts = apply_scopes(Advert.post_scraped)
               .order(ad_creation_time: :desc)
               .page(params[:page])

    @campaign = @adverts.first.funded_by.campaign
    @hosts = apply_scopes(Advert).with_hosts


    add_breadcrumbs_for_campaign_ad_codes!
    add_breadcrumbs_for_scopes!
  end

  def show
    @advert = Advert.find(params[:id])
    @campaign = @advert.funded_by.campaign
    @ad_codes = AdCode.where(campaign: @campaign).group_by(&:index)

    add_breadcrumbs_for_campaign_ad_codes!
    breadcrumb 'Advert', request.path
  end

  def decode_a_link; end
end

