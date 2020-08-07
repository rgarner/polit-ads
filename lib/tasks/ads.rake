require 'polit_ads'

namespace :ads do
  desc 'Scrape ads of interest and collect their external urls'
  task :scrape do
    PolitAds::Scraper.new.run!
  end

  desc 'Fill in everything from external_url post-scrape'
  task post_scrape: %w[populate:utm_campaign_values populate:hosts populate:funding_entities]

  namespace :populate do
    desc 'populate hosts'
    task :hosts do
      PolitAds::HostsPopulator.run
    end

    desc 'Populate utm_campaign_values for any ads that have it in their external_url'
    task :utm_campaign_values do
      PolitAds::UtmCampaignSplitter.new.populate
    end

    desc 'Populate funding entity ids'
    task :funding_entities do
      PolitAds::FundingEntityPopulator.populate
    end
  end

  desc 'Export to CSV'
  task :export do
    PolitAds::CSVToConsole.new.run!
  end

  namespace :utm_campaign do
    desc 'Show me Biden stuffs'
    task :biden do
      require 'addressable'

      h = Hash.new(0)
      Advert.biden.populated.limit(5000).each do |ad|
        url = Addressable::URI.parse(ad.external_url)
        next unless url.query_values && url.query_values['source']

        values = url.query_values['source'].split(/[_|]/)
        h[values.length] = h[values.length] + 1
        pp values, ad.ad_creation_time if values.length == 5
      end

      pp h
    end

    desc 'Print utm_campaign_values for any ads that have it in their external_url'
    task :print, [:limit] do |_t, args|
      limit = args[:limit] || 200
      PolitAds::UtmCampaignSplitter.new.print(limit: limit)
    end

    desc 'Print discrete values for all Trump indices'
    task :trump_discrete do
      count = Advert
              .where("page_name ILIKE '%trump' OR adverts.funding_entity ILIKE '%trump%'")
              .where('external_url IS NOT NULL').count
      puts "From #{count} recent ads with a page_name/funding_entity containing 'Trump'"
      (0..22).each do |i|
        occurrences = UtmCampaignValue
                      .select(:value)
                      .group(:value)
                      .joins(:advert)
                      .where("adverts.page_name ILIKE '%trump' OR adverts.funding_entity ILIKE '%trump%'")
                      .where(index: i).count

        sorted = occurrences.sort do |a, b|
          next 0 if a.last == b.last

          a.last > b.last ? -1 : 1
        end.to_h

        puts "#{i}:"
        sorted.each_pair do |key, value|
          puts "\t#{key}: #{value}"
        end
      end
    end
  end
end
