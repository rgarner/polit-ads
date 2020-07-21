class Advert < ActiveRecord::Base
  validates_presence_of :page_name, :funding_entity, :ad_snapshot_url

  scope :ads_of_interest, -> do
    where("adverts.page_name = 'Joe Biden' OR adverts.page_name = 'Donald J. Trump'")
  end
end