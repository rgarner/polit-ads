require 'addressable'

module PolitAds
  ##
  # Find adverts in need of utm_campaign_values.
  # Split those out from the query string values and insert them into utm_campaign_values
  class UtmCampaignSplitter
    attr_reader :logger

    def initialize(logger: Logger.new(STDERR))
      @logger = logger
    end

    def populate
      Advert.needs_utm_campaign_values.find_each do |advert|
        utm_campaign_values = utm_campaign_values(advert)

        logger.info "'#{advert.ad_creative_link_title}' gets #{utm_campaign_values.length} utm_campaign values"
        utm_campaign_values.each_with_index do |value, index|
          advert.utm_campaign_values.build(index: index, value: value)
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
