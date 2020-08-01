class Advert < ActiveRecord::Base
  has_many :utm_campaign_values, -> { order(:index) }
  belongs_to :host

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

  scope :has_utm_campaign_query_param, lambda {
    left_joins(:utm_campaign_values).where("adverts.external_url ~ '\\?.*utm_campaign'")
  }

  scope :needs_utm_campaign_values, lambda {
    left_joins(:utm_campaign_values)
      .where("adverts.external_url ~ '\\?.*utm_campaign' AND utm_campaign_values.index IS NULL")
  }

  scope :has_utm_campaign_values, lambda {
    where('EXISTS(SELECT 1 from utm_campaign_values where utm_campaign_values.advert_id = adverts.id)')
  }

  ##
  # Call example: Advert.with_utm_values(utm0: 'value', utm1: 'value2')
  scope :with_utm_values, lambda { |hash|
    keys = hash.keys.map { |k| k.to_s.sub('utm', '') }
    joins("JOIN (#{values_for_indices(*keys)}) utm_values ON utm_values.advert_id = adverts.id")
      .where("utm_values.value1 = ? AND utm_values.value2 = ?", *hash.values)
  }

  ##
  # Crosstab select for values in two given utm fields, joinable on advert_id
  # so we can do WHERE...AND queries on UTM values as if they were part of adverss
  def self.values_for_indices(index1, index2)
    <<~SQL.freeze
      SELECT advert_id, value1, value2
                FROM crosstab(
                  'select advert_id, index, value
                                from utm_campaign_values
                                where index in (#{index1},#{index2})
                                order by 1,2'
                )
                AS ct(advert_id bigint, value1 character varying, value2 character varying)
                GROUP BY advert_id, value1, value2
    SQL
  end

  def fb_ad_id
    @fb_ad_id ||= begin
                    matches = ad_snapshot_url.match(/\?id=(?<id>[0-9]*)/)
                    matches[:id]
                  end
  end
end