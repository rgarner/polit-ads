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
  def self.between(campaign, index, start, finish, dimension: 'count')
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      BETWEEN_SQL, 'sql', [[nil, start], [nil, finish], [nil, index], [nil, campaign.id]]
    )

    group_for_chartkick(result, dimension: dimension)
  end

  BETWEEN_SQL =
    <<~SQL.freeze
      SELECT value, start, count, COALESCE(approximate_spend, 0)::bigint AS approximate_spend
      FROM value_daily_summaries
      WHERE start BETWEEN $1 AND $2
        AND index = $3 AND campaign_id = $4
      ORDER BY count DESC, start
    SQL
end
