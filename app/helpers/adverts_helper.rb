module AdvertsHelper
  def badge_class(value)
    "badge badge-#{value == '<empty>' ? 'secondary' : 'primary'}"
  end
end
