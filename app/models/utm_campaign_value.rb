class UtmCampaignValue < ActiveRecord::Base
  belongs_to :advert

  validates :index, presence: true
  validates :value, presence: true
end