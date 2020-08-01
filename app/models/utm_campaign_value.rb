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

  ##
  # Create a two-way contingency table for the two given utm indices by crosstabbing
  # the data at those values with a count of adverts using that data
  class ContingencyTable
    class SameIndexError < StandardError; end

    attr_accessor :index1, :index2

    def initialize(index1, index2)
      raise SameIndexError if index1 == index2

      self.index1 = index1.to_i
      self.index2 = index2.to_i
    end

    def to_a
      rows.each do |row|
        result[row_indices[row['value1']]][col_indices[row['value2']]] = row['count']
      end
      result
    end

    def row_values
      row_indices.keys
    end

    def col_values
      col_indices.keys
    end

    private

    def rows
      @rows ||= ActiveRecord::Base.connection.execute(crosstab_sql)
    end

    def row_indices
      @row_indices ||= rows.each_with_object({}) { |row, values| values[row['value1']] ||= values.length }
    end

    def col_indices
      @col_indices ||= rows.each_with_object({}) { |row, values| values[row['value2']] ||= values.length }
    end

    def result
      @result ||= Array.new(row_indices.length) { Array.new(col_indices.length) }
    end

    ##
    # Flip the order when index1 is > than index2
    def desc
      index1.to_i > index2.to_i ? '' : 'DESC'
    end

    def crosstab_sql
      <<~SQL
        SELECT value1, value2, COUNT(*)
          FROM crosstab(
            'select advert_id, index, value
                          from utm_campaign_values
                          where index in (#{index1}, #{index2})
                          order by 1,2 #{desc}'
          )
          AS ct(advert_id bigint, value1 character varying, value2 character varying)
          GROUP BY value1, value2;
      SQL
    end
  end

  def self.combo(index1, index2)
    ContingencyTable.new(index1, index2)
  end
end
