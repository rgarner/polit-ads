##
# Describe a single value like 'md'
# with a +#value_name+ like "Monthly donor"
# and some markdown in the +#description+
class AdCodeValueDescription < ApplicationRecord
  belongs_to :ad_code
end
