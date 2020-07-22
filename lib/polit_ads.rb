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
require 'polit_ads/utm_campaign_splitter'
require 'advert'
require 'utm_campaign_value'

PolitAds::DB.configure
