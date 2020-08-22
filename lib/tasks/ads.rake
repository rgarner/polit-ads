require 'polit_ads/scraper'
require 'polit_ads/hosts_populator'
require 'polit_ads/utm_campaign_splitter'
require 'polit_ads/utm_values_populator'
require 'polit_ads/funding_entity_populator'

namespace :ads do
  desc 'Scrape ads of interest and collect their external urls'
  task :scrape, %i[limit threads] => [:environment] do |_t, args|
    logger = Logger.new(STDERR)
    logger.level = :info

    limit = (args[:limit] || 1000)
    threads = (args[:threads] || 3)
    PolitAds::Scraper.new(logger: logger, limit: limit, threads: threads).run!
  end

  desc 'Fill in everything from external_url post-scrape'
  task post_scrape: %w[
    populate:hosts
    populate:utm_campaign_values
    populate:funding_entities
    populate:ad_code_value_summaries
  ]

  namespace :populate do
    desc 'populate hosts'
    task hosts: :environment do
      PolitAds::HostsPopulator.run
    end

    desc 'Populate utm_campaign_values for any ads that have it in their external_url'
    task utm_campaign_values: :environment do
      PolitAds::UtmCampaignSplitter.new.populate
      PolitAds::UtmValuesPopulator.populate
    end

    desc 'Populate funding entity ids'
    task funding_entities: :environment do
      PolitAds::FundingEntityPopulator.populate
    end

    desc 'Populate materialized view for ad code summaries'
    task ad_code_value_summaries: :environment do
      $stderr.puts 'Refreshing ad_code_value_summaries materialized view...'
      AdCodeValueSummary.refresh
    end
  end

  namespace :utm_campaign do
    desc 'Show me Biden stuffs'
    task biden: :environment do
      require 'addressable'

      h = Hash.new(0)
      Advert.biden.populated.limit(5000).each do |ad|
        url = Addressable::URI.parse(ad.external_url)
        next unless url.query_values && url.query_values['source']

        values = url.query_values['source'].split(/[_|]/)
        h[values.length] = h[values.length] + 1
        puts "#{ad.ad_creation_time}: #{url.host}(#{values.length}) – #{values} "
      end

      pp h
    end
  end
end
