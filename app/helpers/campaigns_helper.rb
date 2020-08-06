module CampaignsHelper
  def advert_count_text
    "#{number_with_delimiter(@campaigns.map(&:ad_count).reduce(&:+))} adverts"
  end

  def ad_code_path(slug)
    slug == 'trump' ? utm_campaign_values_path : '#'
  end
end
