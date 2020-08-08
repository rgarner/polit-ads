class AdvertsController < ApplicationController
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

  def by_utm_value
    @value = UtmCampaignValue.where(value: params[:utm_value]).first
    base_scope = Advert
                 .joins(:utm_campaign_values)
                 .where('utm_campaign_values.value = ?', params[:utm_value])
    @adverts = base_scope.order(ad_creation_time: :desc).page(params[:page])
    @min_max = base_scope.select('MIN(ad_creation_time) AS min, MAX(ad_creation_time) AS max')[0]

    breadcrumb "#{@value} / adverts", request.path
  end

  private

  ##
  # /adverts?<big-query-string> is the destination for a lot of things.
  # For certain combinations, we know where we're likely to have come from.
  # Work those out here.
  def add_breadcrumbs_for_scopes!
    case current_scopes
    in { hostname: hostname, with_utm_values: utm_values } if utm_values.length == 1
      breadcrumb_values_against_hosts(hostname, utm_values)
    in { with_utm_values: utm_values } if utm_values.length == 2
      breadcrumb_utm_against_utm(utm_values)
    else
      nil
    end
  end

  # We most likely came from utmM against utmN
  def breadcrumb_utm_against_utm(utm_values)
    indices = utm_values.keys

    breadcrumb "utm#{indices.first}", utm_campaign_value_path(indices.first)
    breadcrumb "against utm#{indices.last}", utm_campaign_value_against_path(indices.first, indices.last)
    breadcrumb 'adverts', request.path
  end

  # We most likely came from utm values against hosts
  def breadcrumb_values_against_hosts(hostname, utm_values)
    key, value = utm_values.to_a.first

    breadcrumb "utm#{key}", utm_campaign_value_path(key)
    breadcrumb "#{value} and #{hostname} / adverts", request.path
  end
end

