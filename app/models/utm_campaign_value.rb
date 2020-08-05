class UtmCampaignValue < ActiveRecord::Base
  belongs_to :advert

  validates :index, presence: true
  validates :value, presence: true

  def to_s
    value
  end

  def to_param
    index.to_s
  end

  def self.combo(index1, index2)
    ContingencyTable.new(index1, index2)
  end

  ##
  # Return a list of hashes in a form required by Chartkick,
  # e.g. { name: 'djt', data: { '2020-08-04' => 43, '2020-08-05' => 17 }  }
  def self.between(index, start, finish)
    start = start.strftime('%Y-%m-%d')
    finish = finish.strftime('%Y-%m-%d')

    result = ActiveRecord::Base.connection.exec_query(
      between_sql, 'sql', [[nil, start], [nil, finish], [nil, index]]
    )

    # Map e.g
    # [
    #   {"value"=>"cm", "start"=>"2020-08-03", "count"=>122},
    #   {"value"=>"cm", "start"=>"2020-08-04", "count"=>1420},
    # ]
    # to
    # { name: 'cm', data: [['2020-08-03', 122], ['2020-08-04', 1420]] }

    result.group_by { |row| row['value'] }
          .each_with_object([]) do |(series, values), list|
      list << {
        name: series,
        data: values.map { |value| [value['start'], value['count']] }
      }
    end
  end

  def self.between_sql
    <<~SQL
      SELECT u.value, days.start::date, COUNT(*)
      FROM (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
            FROM generate_series(
                         $1::timestamptz,
                         $2::timestamptz, '1 day'
                     ) AS start
           ) AS days
      JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
      JOIN utm_campaign_values u on adverts.id = u.advert_id AND u.index = $3
      GROUP BY days.start, u.value
      ORDER BY COUNT(*) DESC, days.start
    SQL
  end
end
