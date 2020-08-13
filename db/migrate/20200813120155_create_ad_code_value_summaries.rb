class CreateAdCodeValueSummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :ad_code_value_summaries, materialized: true
  end
end
