require 'polit_ads'

namespace :ads do
  desc 'Scrape ads of interest and collect their external urls'
  task :scrape do
    PolitAds::Scraper.new.run!
  end

  namespace :utm_campaign do
    desc 'Populate utm_campaign_values for any ads that have it in their external_url'
    task :populate do
      PolitAds::UtmCampaignSplitter.new.populate
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
