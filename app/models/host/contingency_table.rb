class Host
  class ContingencyTable
    class SameIndexError < StandardError; end

    attr_accessor :rows

    ##
    # rows needs these cols:
    #   utm_campaign_values.value, hosts.hostname, hosts.purpose, COUNT(*)
    def initialize(rows)
      self.rows = rows
    end

    def to_a
      rows.each do |row|
        result[row_indices[row['hostname']]][col_indices[row['value']]] = row['count']
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

    def row_indices
      @row_indices ||= rows.each_with_object({}) { |row, values| values[row['hostname']] ||= values.length }
    end

    def col_indices
      @col_indices ||= rows.each_with_object({}) { |row, values| values[row['value']] ||= values.length }
    end

    def row_by_hostname
      @row_by_hostname ||= rows.each_with_object({}) { |row, values| values[row['hostname']] ||= row }
    end

    def result
      @result ||= Array.new(row_indices.length) { Array.new(col_indices.length) }
    end
  end
end
