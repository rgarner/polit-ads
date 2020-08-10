class Host < ActiveRecord::Base
  include ChartkickGrouping

  has_many :adverts
  belongs_to :campaign, inverse_of: :hosts

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

  def self.summary_graph_data(date = Date.today)
    sql = <<~SQL
      SELECT hosts.hostname,
             days.start::date, COUNT(*)
      FROM (select start, start + '23 hours 59 minutes 59 seconds' AS end
            from generate_series(
                         '2020-07-01'::timestamptz,
                         $1::timestamptz, '1 day'
                     ) AS start
           ) AS days
               JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
               JOIN hosts ON adverts.host_id = hosts.id
      GROUP BY days.start, hosts.hostname
      ORDER BY COUNT(*) DESC
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql, 'sql', [[nil, date.strftime('%Y-%m-%d')]]
    )

    group_for_chartkick(result, by: 'hostname')
  end
end
