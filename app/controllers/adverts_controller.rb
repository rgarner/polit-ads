class AdvertsController < ApplicationController
  include AdvertsController::Breadcrumbs

  breadcrumb 'UTM Campaign Values', :utm_campaign_values_path, match: :exclusive, except: :show

  has_scope :with_utm_values, type: :hash
  has_scope :hostname

  def index
    @adverts = apply_scopes(Advert.post_scraped)
               .order(ad_creation_time: :desc)
               .page(params[:page])

    add_breadcrumbs_for_scopes!
  end

  def show
    @advert = Advert.find(params[:id])
    breadcrumb 'Advert', request.path
  end
end

