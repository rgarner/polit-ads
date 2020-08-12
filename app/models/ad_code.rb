class AdCode < ApplicationRecord
  belongs_to :campaign

  def to_s
    name
  end

  def to_param
    index
  end
end
