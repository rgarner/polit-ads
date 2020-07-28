##
# Module that has PolitAds.root like Rails.root
module PolitAds
  def self.root
    File.join(File.dirname(__FILE__), '..')
  end
end

$LOAD_PATH.unshift(File.join(PolitAds.root, 'app'))
$LOAD_PATH.unshift(File.join(PolitAds.root, 'app', 'models'))

require 'polit_ads/db'
require 'polit_ads/scraper'
require 'advert'
require 'host'
require 'polit_ads/hosts_populator'
require 'polit_ads/utm_campaign_splitter'
require 'polit_ads/csv_to_console'
require 'utm_campaign_value'

PolitAds::DB.configure
