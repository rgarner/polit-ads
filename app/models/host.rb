class Host < ActiveRecord::Base
  has_many :adverts

  def to_s
    hostname
  end
end