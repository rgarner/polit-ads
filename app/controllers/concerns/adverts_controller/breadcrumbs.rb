class AdvertsController
  module Breadcrumbs
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
      in { with_utm_values: utm_values } if utm_values.length == 1
        breadcrumb_utm(utm_values)
      else
        nil
      end
    end

    def breadcrumb_utm(utm_values)
      index = utm_values.keys.first
      ad_code = AdCode.for_trump.find_by(index: index)

      breadcrumb ad_code.full_name, campaign_ad_code_path(ad_code.campaign, index)
      breadcrumb "#{utm_values.values.first} adverts", request.path
    end

    def humanize_utm(utm_values)
      utm_values.map do |key, value|
        "'#{value}'"
      end.join(' and ')
    end

    # We most likely came from utmM against utmN
    def breadcrumb_utm_against_utm(utm_values)
      ad_codes = utm_values.keys.map { |index| AdCode.for_trump.find_by(index: index) }

      breadcrumb ad_codes.first.full_name, campaign_ad_code_path(ad_codes.first.campaign, ad_codes.first.index)
      breadcrumb "against #{ad_codes.last.full_name}", campaign_ad_code_against_path(ad_codes.first.campaign, ad_codes.first.index, ad_codes.last.index)
      breadcrumb humanize_utm(utm_values), request.path
    end

    # We most likely came from utm values against hosts
    def breadcrumb_values_against_hosts(hostname, utm_values)
      key, value = utm_values.to_a.first

      breadcrumb "utm#{key}", utm_campaign_value_path(key)
      breadcrumb "#{value} and #{hostname} / adverts", request.path
    end
  end
end
