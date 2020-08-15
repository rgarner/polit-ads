class AdCode < ApplicationRecord
  belongs_to :campaign

  scope :for_trump, -> { joins(:campaign).where("campaigns.slug = 'trump'") }

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
