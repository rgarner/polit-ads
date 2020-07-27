class Advert < ActiveRecord::Base
  has_many :utm_campaign_values
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
end