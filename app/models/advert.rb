class Advert < ActiveRecord::Base
  validates_presence_of :page_name, :funding_entity, :ad_snapshot_url

  scope :ads_of_interest, lambda {
    where(
      "adverts.page_name = 'Joe Biden' OR " \
      "adverts.page_name = 'Donald J. Trump'"
    )
  }

  scope :recent, lambda {
    order(ad_creation_time: :desc)
  }

  scope :unpopulated, -> { where(external_url: nil) }
end