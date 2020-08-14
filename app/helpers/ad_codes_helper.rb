module AdCodesHelper
  def new_ad_code?(ad_code, days = 2)
    threshold = Date.today - days.to_i
    ad_code.first_used > threshold
  end
end
