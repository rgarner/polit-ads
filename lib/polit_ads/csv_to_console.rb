require 'csv'

module PolitAds
  ##
  # Export CSV adverts to STDOUT. Pipe to file as necessary.
  # Check #adverts method for scope, currently fixed on Trump
  class CSVToConsole
    LIMIT = 5000

    FIELDS = %w[
      page_name
      host
      ad_creation_time
      ad_snapshot_url
      ad_library_url
      external_url
      ad_creative_body
    ].freeze

    def run!
      puts header
      adverts.each { |advert| puts CSV.generate_line(values_for(advert)) }
    end

    private

    def header
      (FIELDS + utm_indices).join(',')
    end

    def utm_indices
      (0..22).each_with_object([]) { |utm_index, indices| indices << "utm#{utm_index}" }
    end

    def values_for(advert)
      values = FIELDS.map { |attr| advert.send(attr) }
      advert.utm_campaign_values.each { |value| values << value.value }
      values
    end

    def adverts
      Advert.has_utm_campaign_values.trump.order(ad_creation_time: :desc).limit(LIMIT)
    end
  end
end