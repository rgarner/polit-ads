class AdCodeValueUsage < ActiveRecord::Base
  include ChartkickGrouping

  belongs_to :advert

  validates :index, presence: true
  validates :value, presence: true

  def self.by_host(campaign_id, index)
    select('ad_code_value_usages.value, hosts.hostname, hosts.purpose, COUNT(*)')
      .where(index: index)
      .joins(advert: :host)
      .joins(advert: :funded_by)
      .where('funding_entities.campaign_id = ?', campaign_id)
      .group('ad_code_value_usages.value, hosts.id')
      .order(count: :desc)
  end

  def to_s
    value
  end

  def to_param
    index.to_s
  end

  ##
  # Return a list of hashes in a form required by Chartkick,
  # e.g. { name: 'djt', data: { '2020-08-04' => 43, '2020-08-05' => 17 }  }
  def self.between(campaign, index, start, finish)
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      BETWEEN_SQL, 'sql', [[nil, start], [nil, finish], [nil, index], [nil, campaign.id]]
    )

    group_for_chartkick(result)
  end

  BETWEEN_SQL =
    <<~SQL.freeze
      SELECT u.value, days.start::date, COUNT(*)
      FROM (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
            FROM generate_series(
                         $1::timestamptz,
                         $2::timestamptz, '1 day'
                     ) AS start
           ) AS days
      JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
      JOIN ad_code_value_usages u on adverts.id = u.advert_id AND u.index = $3
      JOIN funding_entities ON funding_entities.id = adverts.funding_entity_id
      WHERE adverts.host_id IS NOT NULL
      AND funding_entities.campaign_id = $4
      GROUP BY days.start, u.value
      ORDER BY COUNT(*) DESC, days.start
    SQL
end