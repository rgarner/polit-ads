class AdCode < ApplicationRecord
  belongs_to :campaign

  has_many :ad_code_value_summaries

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
