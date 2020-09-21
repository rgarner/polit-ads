module AdvertsHelper
  def badge_class(usage)
    "badge badge-#{usage.value == '<empty>' ? 'secondary' : 'primary'}"
  end
end
