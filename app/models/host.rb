class Host < ActiveRecord::Base
  has_many :adverts

  scope :with_ad_counts, lambda {
    select('hosts.*, MIN(adverts.ad_creation_time) AS ad_first, '\
           'MAX(adverts.ad_creation_time) AS ad_last, COUNT(adverts.id) AS ad_count')
      .joins(:adverts)
      .group('hosts.id')
      .order('COUNT(adverts.id) DESC')
  }

  def to_s
    hostname
  end
end
