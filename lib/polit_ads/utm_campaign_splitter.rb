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

    EMPTY = '<empty>'.freeze

    def populate
      Advert.trump.has_utm_campaign_query_param.needs_ad_code_value_usages.find_each do |advert|
        utm_campaign_values = utm_campaign_values(advert)

        logger.info "'#{advert.ad_creative_link_title}' gets #{utm_campaign_values.length} utm_campaign values"
        utm_campaign_values.each_with_index do |value, index|
          advert.ad_code_value_usages.build(index: index, value: value.present? ? value : EMPTY)
        end
        advert.save!
      end
    end

    private

    ##
    # Normalize for any shonky values
    class TrumpUtmNormalizer
      URL_CARRYING_A_VALUE = %r{https://vote\.donaldjtrump\.com/\?(?<value>.*)}.freeze

      attr_reader :utm_values

      def initialize(utm_values)
        @utm_values = utm_values.split('_')
      end

      def elv_urls_at_1_and_14?
        utm_values[1] =~ URL_CARRYING_A_VALUE && utm_values[14] =~ URL_CARRYING_A_VALUE
      end

      def value_carried_in_url(index)
        match = utm_values[index].match(URL_CARRYING_A_VALUE)
        match[:value]
      end

      # @return [Array<String>]
      def remap_elv_values
        ad_campaign = value_carried_in_url(1)
        ad_lp_code = value_carried_in_url(14)

        [
          utm_values[0],
          'na',
          ad_campaign,
          *utm_values[2..13],
          'na',
          ad_lp_code,
          *utm_values[15..]
        ]
      end

      def to_a
        if elv_urls_at_1_and_14?
          remap_elv_values
        else
          utm_values
        end
      end
    end

    def utm_campaign_values(advert)
      url = Addressable::URI.parse(advert.external_url)

      normalizer = TrumpUtmNormalizer.new(url.query_values['utm_campaign'])
      normalizer.to_a
    end
  end
end
