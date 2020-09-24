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
    def group_for_chartkick(result, by: 'value', dimension: 'count')
      result.group_by { |row| row[by] }
            .each_with_object([]) do |(series, values), list|
        list << {
          name: series,
          data: values.map { |value| [value['start'], value[dimension]] }
        }
      end
    end
  end
end
