class AdCode < ApplicationRecord
  belongs_to :campaign

  def full_name
    "#{name} (utm#{index})"
  end

  def to_s
    name
  end

  def to_param
    index
  end
end
