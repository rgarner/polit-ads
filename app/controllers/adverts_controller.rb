class AdvertsController < ApplicationController
  include AdvertsController::Breadcrumbs

  breadcrumb 'Donald J. Trump', :current
  breadcrumb 'Ad codes', -> { campaign_ad_codes_path(campaign_id: 'trump') },
             match: :exclusive, except: :show

  has_scope :with_utm_values, type: :hash
  has_scope :hostname

  def index
    @adverts = apply_scopes(Advert.post_scraped)
               .order(ad_creation_time: :desc)
               .page(params[:page])

    @hosts = apply_scopes(Advert).with_hosts


    add_breadcrumbs_for_scopes!
  end

  def show
    @advert = Advert.find(params[:id])
    @ad_codes = AdCode.where(campaign: @advert.funded_by.campaign).group_by(&:index)
    breadcrumb 'Advert', request.path
  end
end

