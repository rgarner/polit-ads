class AdCodeValueSummary < ApplicationRecord
  belongs_to :campaign

  # Bring in value_name, if it's there
  scope :with_value_names, lambda {
    select('ad_code_value_summaries.*, ad_code_value_descriptions.value_name,' \
           'ad_codes.short_desc'
    )
      .joins('LEFT JOIN ad_code_value_descriptions ON ' \
             'ad_code_value_descriptions.ad_code_id = ad_code_value_summaries.ad_code_id AND ' \
             'ad_code_value_descriptions.value = ad_code_value_summaries.value')
      .joins('JOIN ad_codes ON ad_codes.id = ad_code_value_summaries.ad_code_id')
      .order('quality DESC, ad_codes.id')
  }

  def full_name
    "#{name} (utm#{index})"
  end

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
