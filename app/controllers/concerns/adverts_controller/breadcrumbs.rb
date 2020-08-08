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
      breadcrumb "utm#{utm_values.keys.first}", utm_campaign_value_path(utm_values.keys.first)
      breadcrumb "#{utm_values.values.first} adverts", request.path
    end

    def humanize_utm(utm_values)
      utm_values.map do |key, value|
        "utm#{key}: '#{value}'"
      end.join(' and ')
    end

    # We most likely came from utmM against utmN
    def breadcrumb_utm_against_utm(utm_values)
      indices = utm_values.keys

      breadcrumb "utm#{indices.first}", utm_campaign_value_path(indices.first)
      breadcrumb "against utm#{indices.last}", utm_campaign_value_against_path(indices.first, indices.last)
      breadcrumb "adverts with #{humanize_utm(utm_values)}", request.path
    end

    # We most likely came from utm values against hosts
    def breadcrumb_values_against_hosts(hostname, utm_values)
      key, value = utm_values.to_a.first

      breadcrumb "utm#{key}", utm_campaign_value_path(key)
      breadcrumb "#{value} and #{hostname} / adverts", request.path
    end
  end
end
