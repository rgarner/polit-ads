class UpdateAdCodeValueSummariesToVersion4 < ActiveRecord::Migration[6.0]
  def change
    update_view :ad_code_value_summaries, version: 4, revert_to_version: 3, materialized: true
  end
end
