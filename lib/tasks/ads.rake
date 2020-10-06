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
    populate:impressions
    populate:ad_code_daily_summaries
    populate:ad_code_value_summaries
    populate:campaign_daily_summaries
    populate:host_daily_summaries
    populate:value_daily_summaries
    populate:wants_key
  ]

  namespace :watch do
    desc 'Watch descriptions for edits and reload them'
    task :descriptions do
      sh 'rerun -d doc/ad_code_values -- bundle exec rake ads:populate:descriptions'
    end
  end

  namespace :backfill do
    desc 'backfill impressions month to month. Larger sets cause infinite* queries'
    task impressions: :environment do
      oldest_month = 6
      this_month = Date.today.month
      (oldest_month..this_month).each do |month|
        system(
          "make clean impressions.csv update-impressions \\
            IMPRESSIONS_FROM=2020-#{month}-01 \\
            IMPRESSIONS_TO=2020-#{(month + 1) % 12}-01"
        )
      end
    end

  end

  namespace :populate do
    desc 'populate hosts'
    task hosts: :environment do
      PolitAds::HostsPopulator.run
    end

    desc 'populate recent impressions'
    task impressions: :environment do
      oldest_day = (Date.today - 7).strftime('%Y-%m-%d')
      newest_day = (Date.tomorrow).strftime('%Y-%m-%d')
      system(
        "make clean impressions.csv update-impressions \\
          IMPRESSIONS_FROM=#{oldest_day} \\
          IMPRESSIONS_TO=#{newest_day}"
      )
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

    desc 'Populate materialized view for ad code daily summaries'
    task ad_code_daily_summaries: :environment do
      $stderr.puts 'Refreshing ad_code_daily_summaries materialized view...'
      AdCodeDailySummary.refresh
    end

    desc 'Populate materialized view for campaign daily summaries'
    task campaign_daily_summaries: :environment do
      $stderr.puts 'Refreshing campaign_daily_summaries materialized view...'
      CampaignDailySummary.refresh
    end

    desc 'Populate materialized view for host daily summaries'
    task host_daily_summaries: :environment do
      $stderr.puts 'Refreshing host_daily_summaries materialized view...'
      HostDailySummary.refresh
    end

    desc 'Populate materialized view for value daily summaries'
    task value_daily_summaries: :environment do
      $stderr.puts 'Refreshing value_daily_summaries materialized view...'
      ValueDailySummary.refresh
    end

    desc 'Populate ad code and ad code value descriptions'
    task descriptions: :environment do
      AdCodeDescriptionsLoader.new('doc/ad_codes').create_or_update
      AdCodeValueDescriptionsLoader.new('doc/ad_code_values').create_or_update
    end

    desc 'populate wants_key; UPDATE SET wants_key = ? first to recalculate selectively'
    task wants_key: :environment do
      ads = Advert.where('wants_key IS NULL AND hosts.purpose IS NOT NULL')
                  .joins(:host)
                  .order(ad_creation_time: :desc)
      puts "Filling wants_key for #{ads.count} ads"

      ads.find_each do |ad|
        if ad.host.nil?
          warn "#{ad.id} has no host"
          next
        end

        decoding = Decoding.create(ad)
        ad.update_attribute(:wants_key, decoding.wants_key)
      rescue StandardError
        warn "#{ad.id} #{ad.host.hostname}"
        raise
      end
    end
  end
end
