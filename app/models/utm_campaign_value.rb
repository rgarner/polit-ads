class UtmCampaignValue < ActiveRecord::Base
  belongs_to :advert

  validates :index, presence: true
  validates :value, presence: true

  def to_s
    value
  end

  def to_param
    index.to_s
  end
end