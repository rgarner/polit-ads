require 'polit_ads'

namespace :ads do
  desc 'Scrape ads of interest and collect their external urls'
  task :scrape do
    PolitAds::Scraper.new.scrape!
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
  end
end
