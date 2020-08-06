module CampaignsHelper
  def advert_count_text
    "#{number_with_delimiter(@campaigns.map(&:ad_count).reduce(&:+))} adverts"
  end
end
