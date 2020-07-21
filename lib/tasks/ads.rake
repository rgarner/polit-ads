require 'polit_ads'

namespace :ads do
  desc 'Scrape ads of interest and collect their external urls'
  task :scrape do
    PolitAds::Scraper.new.scrape!
  end
end
