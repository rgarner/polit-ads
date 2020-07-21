class CreateAdverts < ActiveRecord::Migration[6.0]
  def change
    create_table :adverts do |t|
      t.string "page_id", limit: 25, null: false
      t.text "page_name"
      t.string "post_id", limit: 25, null: false
      t.string "country", limit: 10, null: false
      t.datetime "ad_creation_time"
      t.text "ad_creative_body"
      t.text "ad_creative_link_caption"
      t.text "ad_creative_link_description"
      t.text "ad_creative_link_title"
      t.datetime "ad_delivery_start_time"
      t.datetime "ad_delivery_stop_time"
      t.text "ad_snapshot_url"
      t.text "image_link"
      t.string "currency", limit: 10
      t.text "funding_entity"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "ad_info"
      t.tsvector "text_search"
    end
  end
end
