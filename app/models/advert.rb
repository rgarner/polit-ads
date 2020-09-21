class Advert < ActiveRecord::Base
  has_many :ad_code_value_usages, -> { order(:index) }
  belongs_to :host
  belongs_to :funded_by, class_name: 'FundingEntity', foreign_key: 'funding_entity_id'

  validates_presence_of :page_name, :funding_entity, :ad_snapshot_url

  FUNDING_ENTITIES_TRUMP = [
    'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE',
    'DONALD J. TRUMP FOR PRESIDENT, INC.'
  ].freeze

  FUNDING_ENTITIES_BIDEN = [
    'BIDEN FOR PRESIDENT',
    'BIDEN VICTORY FUND',
    'Biden for President'
  ].freeze

  scope :trump, -> { where('adverts.funding_entity IN (?)', FUNDING_ENTITIES_TRUMP) }
  scope :biden, -> { where('adverts.funding_entity IN (?)', FUNDING_ENTITIES_BIDEN) }
  scope :trump_or_biden, -> { where('adverts.funding_entity IN (?)', FUNDING_ENTITIES_BIDEN + FUNDING_ENTITIES_TRUMP) }

  scope :recent, lambda {
    order(ad_creation_time: :desc)
  }

  scope :unpopulated,  -> { where(external_url: nil) }
  scope :populated,    -> { where('adverts.external_url IS NOT NULL') }
  scope :post_scraped, -> { where('adverts.host_id IS NOT NULL') }

  scope :has_utm_campaign_query_param, lambda {
    where("adverts.external_url ~ '\\?.*utm_campaign'")
  }

  scope :has_source_query_param, lambda {
    where("adverts.external_url ~ '[&?]source='")
  }

  scope :needs_ad_code_value_usages, lambda {
    left_joins(:ad_code_value_usages).where('ad_code_value_usages.index IS NULL')
  }

  scope :has_ad_code_value_usages, lambda {
    where('EXISTS(SELECT 1 from ad_code_value_usages where ad_code_value_usages.advert_id = adverts.id)')
  }

  ##
  # Call example: Advert.with_utm_values('0' => 'value', '1' => 'value2')
  scope :with_utm_values, lambda { |hash|
    where('utm_values @> ?', hash.to_json)
  }

  scope :with_hosts, lambda {
    select('hosts.*, MIN(adverts.ad_creation_time) AS ad_first, '\
           'MAX(adverts.ad_creation_time) AS ad_last, COUNT(adverts.id) AS ad_count')
      .joins(:host)
      .group('hosts.id')
  }

  scope :hostname, lambda { |hostname|
    joins(:host).where('hosts.hostname = ?', hostname)
  }

  def fb_ad_id
    @fb_ad_id ||= begin
                    matches = ad_snapshot_url.match(/\?id=(?<id>[0-9]*)/)
                    matches[:id]
                  end
  end
end
