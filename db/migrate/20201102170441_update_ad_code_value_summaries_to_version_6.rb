class UpdateAdCodeValueSummariesToVersion6 < ActiveRecord::Migration[6.0]
  def change
    update_view :ad_code_value_summaries,
      version: 6,
      revert_to_version: 5,
      materialized: true
  end
end
