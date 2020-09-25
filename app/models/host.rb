class Host < ActiveRecord::Base
  include ChartkickGrouping

  has_many :adverts
  belongs_to :campaign, inverse_of: :hosts

  scope :with_ad_counts, lambda {
    select('hosts.*, MIN(adverts.ad_creation_time) AS ad_first, '\
           'MAX(adverts.ad_creation_time) AS ad_last, COUNT(*) AS ad_count')
      .joins(:adverts)
      .group('hosts.id')
      .order('COUNT(adverts.id) DESC')
  }

  def to_s
    hostname
  end

  def self.summary_graph_data
    result = ActiveRecord::Base.connection.exec_query('SELECT * FROM host_daily_summaries')
    group_for_chartkick(result, by: 'hostname')
  end
end
