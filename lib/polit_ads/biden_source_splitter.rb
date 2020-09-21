require 'addressable'

module PolitAds
  ##
  # Find Biden adverts in need of ad_code_value_usages.
  # Split those out from the query string values and insert them into ad_code_value_usages.
  #
  # There are three schemes:
  # a "full" bid14 scheme, consisting of 14 fields, six of which are separated by `_` and 9 by `|`, eg:
  #   omvf_fb_20200716teamjoe_EA_014leftM_FB_US_18-65_MF_a002_Graphic2Copy1_STA_SU_SQ
  # a 6-value scheme in which the 6th param is equivalent to the 9th "audience" in the bid14 scheme, eg:
  #   omvf_fb_20200812getinvolved_ea_000_a002
  # a 5-value scheme:
  #   om_fb_vpfirsttoknow_acq_view10
  class BidenSourceSplitter
    attr_reader :logger

    def initialize(logger: Logger.new(STDERR))
      @logger = logger
    end

    def populate
      Advert.biden.has_source_query_param.needs_ad_code_value_usages.find_each do |advert|
        source_values = source_values(advert)

        logger.info "'#{advert.ad_creative_link_title}' gets #{source_values.length} source values"
        source_values.each_with_index do |value, index|
          advert.ad_code_value_usages.build(index: index, value: value)
        end
        advert.save!
      end
    end

    private

    AD_GOAL_INDEX = 3
    AUDIENCE_INDEX = 9
    SCHEME_6_AUDIENCE_INDEX = 5

    def source_values(advert)
      url = Addressable::URI.parse(advert.external_url)
      url.query_values['source'].split(/[_|]/).tap do |values|
        scheme = values.length # 5, 6 or 14

        pad_empty!(values) if scheme != 14
        normalize(scheme, values)
      end
    end

    def normalize(scheme, values)
      values[AD_GOAL_INDEX] = values[AD_GOAL_INDEX].downcase

      if scheme == 6
        values[AUDIENCE_INDEX] = values[SCHEME_6_AUDIENCE_INDEX]
        values[SCHEME_6_AUDIENCE_INDEX] = '<empty>'
      end
    end

    def pad_empty!(values)
      empty_pad = Array.new(14 - values.length, '<empty>')
      values.concat(empty_pad)
    end
  end
end
