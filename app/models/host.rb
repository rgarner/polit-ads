class Host < ActiveRecord::Base
  has_many :adverts

  scope :with_ad_counts, lambda {
    select('hosts.*, COUNT(adverts.id) AS ad_count')
      .joins(:adverts)
      .group('hosts.id')
      .order('COUNT(adverts.id) DESC')
  }

  def to_s
    hostname
  end
end