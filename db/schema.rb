# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_06_100005) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "adverts", force: :cascade do |t|
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
    t.string "external_tracking_url"
    t.string "external_url"
    t.string "external_text"
    t.integer "host_id"
    t.string "ad_library_url"
    t.bigint "funding_entity_id"
    t.index ["funding_entity_id"], name: "index_adverts_on_funding_entity_id"
    t.index ["host_id"], name: "index_adverts_on_host_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true
  end

  create_table "funding_entities", force: :cascade do |t|
    t.string "name"
    t.bigint "campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_funding_entities_on_campaign_id"
    t.index ["name"], name: "index_funding_entities_on_name", unique: true
  end

  create_table "hosts", force: :cascade do |t|
    t.string "hostname"
    t.bigint "campaign_id"
    t.index ["campaign_id"], name: "index_hosts_on_campaign_id"
    t.index ["hostname"], name: "index_hosts_on_hostname", unique: true
  end

  create_table "utm_campaign_values", force: :cascade do |t|
    t.bigint "advert_id"
    t.integer "index", null: false
    t.string "value", null: false
    t.index ["advert_id", "index", "value"], name: "index_utm_campaign_values_on_advert_id_and_index_and_value", unique: true
    t.index ["advert_id"], name: "index_utm_campaign_values_on_advert_id"
    t.index ["index", "value"], name: "index_utm_campaign_values_on_index_and_value"
    t.index ["value"], name: "index_utm_campaign_values_on_value"
  end

end
