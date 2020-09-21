require 'polit_ads/scraper'
require 'polit_ads/hosts_populator'
require 'polit_ads/utm_campaign_splitter'
require 'polit_ads/biden_source_splitter'
require 'polit_ads/utm_values_populator'
require 'polit_ads/funding_entity_populator'
require 'polit_ads/ad_code_descriptions_loader'
require 'polit_ads/ad_code_value_descriptions_loader'

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
    populate:ad_code_value_usages
    populate:funding_entities
    populate:ad_code_value_summaries
  ]

  namespace :watch do
    desc 'Watch descriptions for edits and reload them'
    task :descriptions do
      sh 'rerun -d doc/ad_code_values -- bundle exec rake ads:populate:descriptions'
    end
  end

  namespace :populate do
    desc 'populate hosts'
    task hosts: :environment do
      PolitAds::HostsPopulator.run
    end

    desc 'Populate ad_code_value_usages for any ads that have it in their external_url'
    task ad_code_value_usages: :environment do
      PolitAds::UtmCampaignSplitter.new.populate
      PolitAds::BidenSourceSplitter.new.populate
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

    desc 'Populate ad code and ad code value descriptions'
    task descriptions: :environment do
      AdCodeDescriptionsLoader.new('doc/ad_codes').create_or_update
      AdCodeValueDescriptionsLoader.new('doc/ad_code_values').create_or_update
    end
  end

  namespace :utm_campaign do
    desc 'Show me Biden stuffs'
    task biden: :environment do
      require 'addressable'

      host_lengths = Hash.new(0)
      ads = Advert.biden.populated
      puts ads.count
      ads.each do |ad|
        url = Addressable::URI.parse(ad.external_url)
        next unless url.query_values && url.query_values['source']

        values = url.query_values['source'].split(/[_|]/)

        key = "#{url.host}:#{values.length}"
        puts key
        host_lengths[key] = host_lengths[key] + 1
        # puts "#{ad.ad_creation_time}: #{url.host}(#{values.length}) – #{values} "
      end

      pp host_lengths
    end
  end
end
