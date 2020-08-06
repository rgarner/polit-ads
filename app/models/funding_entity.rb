class FundingEntity < ApplicationRecord
  belongs_to :campaign, inverse_of: :funding_entities

  has_many :adverts
end
