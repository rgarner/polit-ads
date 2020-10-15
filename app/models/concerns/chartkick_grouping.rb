module ChartkickGrouping
  extend ActiveSupport::Concern

  class_methods do
    # Map a three-column result hash with some name and 'start' and 'count' e.g
    # [
    #   {"value"=>"cm", "start"=>"2020-08-03", "count"=>122},
    #   {"value"=>"cm", "start"=>"2020-08-04", "count"=>1420},
    # ]
    # to
    # { name: 'cm', data: [['2020-08-03', 122], ['2020-08-04', 1420]] }
    #
    # +dimension+: defaults to Count, approximate_spend also often available
    # +include+: extra keys from the result row you want at series level
    def group_for_chartkick(result, by: 'value', dimension: 'count', include: [])
      result.group_by { |row| row[by] }
            .each_with_object([]) do |(series, values), list|
        item =  {
          name: series,
          data: values.map { |value| [value['start'], value[dimension]] }
        }

        Array(include).each do |label_key|
          value_name = values.first[label_key.to_s]
          item[label_key.to_sym] = value_name if value_name
        end

        list << item
      end
    end
  end
end
