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
require 'advert'

PolitAds::DB.configure
