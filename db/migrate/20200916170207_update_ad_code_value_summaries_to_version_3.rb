class UpdateAdCodeValueSummariesToVersion3 < ActiveRecord::Migration[6.0]
  def change
    update_view :ad_code_value_summaries, version: 3, revert_to_version: 2, materialized: true
  end
end
