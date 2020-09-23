class UpdateAdCodeValueSummariesToVersion5 < ActiveRecord::Migration[6.0]
  def change
    update_view :ad_code_value_summaries, version: 5, revert_to_version: 4, materialized: true
  end
end
