module AdvertsHelper
  def utm_links_for(utm_value_params)
    utm_value_params.map do |utm_sym, value|
      utm_index = utm_sym.to_s.sub('utm', '')

      (
        link_to(utm_sym, utm_campaign_value_path(utm_index)) << ' = ' <<
        link_to(value, adverts_by_utm_value_path(value))
      )
    end.join(' AND ').html_safe
  end
end