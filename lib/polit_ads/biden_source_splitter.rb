require 'addressable'

module PolitAds
  ##
  # Find Biden adverts in need of ad_code_value_usages.
  # Split those out from the query string values and insert them into ad_code_value_usages
  class BidenSourceSplitter
    attr_reader :logger

    def initialize(logger: Logger.new(STDERR))
      @logger = logger
    end

    def populate
      Advert.biden.needs_ad_code_value_usages.find_each do |advert|
        source_values = source_values(advert)

        logger.info "'#{advert.ad_creative_link_title}' gets #{source_values.length} utm_campaign values"
        source_values.each_with_index do |value, index|
          advert.ad_code_value_usages.build(index: index, value: value)
        end
        advert.save!
      end
    end

    private

    def source_values(advert)
      url = Addressable::URI.parse(advert.external_url)
      url.query_values['source']&.split(/[_|]/) || []
    end
  end
end
