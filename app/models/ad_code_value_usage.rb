class AdCodeValueUsage < ActiveRecord::Base
  belongs_to :advert

  validates :index, presence: true
  validates :value, presence: true

  def self.by_host(campaign_id, index)
    select('ad_code_value_usages.value, hosts.hostname, hosts.purpose, COUNT(*)')
      .where(index: index)
      .joins(advert: :host)
      .joins(advert: :funded_by)
      .where('funding_entities.campaign_id = ?', campaign_id)
      .group('ad_code_value_usages.value, hosts.id')
      .order(count: :desc)
  end

  def to_s
    value
  end

  def to_param
    index.to_s
  end
end
