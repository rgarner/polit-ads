class Advert < ActiveRecord::Base
  has_many :utm_campaign_values, -> { order(:index) }
  belongs_to :host

  validates_presence_of :page_name, :funding_entity, :ad_snapshot_url

  scope :ads_of_interest, lambda {
    where(
      "adverts.page_name = 'Joe Biden' OR " \
      "adverts.page_name = 'Democrats' OR " \
      "adverts.page_name = 'Democratic Party' OR " \
      "adverts.page_name = 'Team Trump' OR " \
      "adverts.page_name = 'Donald J. Trump'"
    )
  }

  FUNDING_ENTITIES_TRUMP = [
    'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE',
    'DONALD J. TRUMP FOR PRESIDENT, INC.'
  ].freeze

  scope :trump, lambda {
    where(
      'adverts.funding_entity IN (?)', FUNDING_ENTITIES_TRUMP
    )
  }

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
end