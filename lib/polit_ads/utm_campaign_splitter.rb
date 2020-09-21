require 'addressable'

module PolitAds
  ##
  # Find Trump adverts in need of ad_code_value_usages.
  # Split those out from the query string values and insert them into ad_code_value_usages
  class UtmCampaignSplitter
    attr_reader :logger

    def initialize(logger: Logger.new(STDERR))
      @logger = logger
    end

    def populate
      Advert.trump.has_utm_campaign_query_param.needs_ad_code_value_usages.find_each do |advert|
        utm_campaign_values = utm_campaign_values(advert)

        logger.info "'#{advert.ad_creative_link_title}' gets #{utm_campaign_values.length} utm_campaign values"
        utm_campaign_values.each_with_index do |value, index|
          advert.ad_code_value_usages.build(index: index, value: value)
        end
        advert.save!
      end
    end

    private

    def utm_campaign_values(advert)
      url = Addressable::URI.parse(advert.external_url)
      url.query_values['utm_campaign'].split('_')
    end
  end
end
