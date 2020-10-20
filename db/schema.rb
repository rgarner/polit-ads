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

ActiveRecord::Schema.define(version: 2020_10_19_205005) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "ad_code_value_descriptions", force: :cascade do |t|
    t.string "value"
    t.string "value_name"
    t.string "confidence"
    t.string "description"
    t.bigint "ad_code_id"
    t.date "published"
    t.index ["ad_code_id"], name: "index_ad_code_value_descriptions_on_ad_code_id"
  end

  create_table "ad_code_value_usages", force: :cascade do |t|
    t.bigint "advert_id"
    t.integer "index", null: false
    t.string "value", null: false
    t.index ["advert_id", "index", "value"], name: "index_ad_code_value_usages_on_advert_id_and_index_and_value", unique: true
    t.index ["advert_id"], name: "index_ad_code_value_usages_on_advert_id"
    t.index ["index", "value"], name: "index_ad_code_value_usages_on_index_and_value"
    t.index ["value"], name: "index_ad_code_value_usages_on_value"
  end

  create_table "ad_codes", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.integer "index"
    t.integer "quality"
    t.bigint "campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.string "confidence"
    t.string "short_desc"
    t.index ["campaign_id", "index"], name: "index_ad_codes_on_campaign_id_and_index", unique: true
    t.index ["campaign_id"], name: "index_ad_codes_on_campaign_id"
  end

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
    t.jsonb "utm_values"
    t.integer "spend_lower_bound"
    t.integer "spend_upper_bound"
    t.jsonb "illuminate_tags"
    t.string "wants_key"
    t.index ["external_url"], name: "index_adverts_on_external_url", using: :hash
    t.index ["funding_entity_id"], name: "index_adverts_on_funding_entity_id"
    t.index ["host_id"], name: "index_adverts_on_host_id"
    t.index ["post_id"], name: "index_adverts_on_post_id"
    t.index ["utm_values"], name: "index_adverts_on_utm_values", using: :gin
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
    t.string "purpose"
    t.index ["campaign_id"], name: "index_hosts_on_campaign_id"
    t.index ["hostname"], name: "index_hosts_on_hostname", unique: true
  end

  add_foreign_key "ad_code_value_descriptions", "ad_codes"

  create_view "host_daily_summaries", materialized: true, sql_definition: <<-SQL
      SELECT hosts.hostname,
      (days.start)::date AS start,
      count(*) AS count,
      sum(round((((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2))::numeric, 2)) AS approximate_spend
     FROM ((( SELECT start.start,
              (start.start + '23:59:59'::interval) AS "end"
             FROM generate_series('2020-07-01 00:00:00+00'::timestamp with time zone, '2020-12-31 00:00:00+00'::timestamp with time zone, '1 day'::interval) start(start)) days
       JOIN adverts ON (((adverts.ad_creation_time >= days.start) AND (adverts.ad_creation_time <= days."end"))))
       JOIN hosts ON ((adverts.host_id = hosts.id)))
    WHERE (adverts.host_id IS NOT NULL)
    GROUP BY days.start, hosts.hostname
    ORDER BY (count(*)) DESC;
  SQL
  create_view "ad_code_value_summaries", materialized: true, sql_definition: <<-SQL
      SELECT ac.id AS ad_code_id,
      fe.campaign_id,
      u.index,
      u.value,
      ac.name,
      ac.quality,
      min(a.ad_creation_time) AS first_used,
      max(a.ad_creation_time) AS last_used,
      count(*) AS count,
      round((((count(*))::numeric / sum(count(*)) OVER w_campaign_index) * (100)::numeric), 2) AS percentage,
      sum(((a.spend_lower_bound + a.spend_upper_bound) / 2)) AS approximate_spend
     FROM ((((ad_code_value_usages u
       JOIN adverts a ON ((u.advert_id = a.id)))
       JOIN funding_entities fe ON ((a.funding_entity_id = fe.id)))
       JOIN campaigns c ON ((fe.campaign_id = c.id)))
       JOIN ad_codes ac ON (((c.id = ac.campaign_id) AND (ac.index = u.index))))
    GROUP BY fe.campaign_id, u.index, u.value, ac.id
    WINDOW w_campaign_index AS (PARTITION BY fe.campaign_id, u.index);
  SQL
  create_view "campaign_daily_summaries", materialized: true, sql_definition: <<-SQL
      SELECT campaigns.id AS campaign_id,
      campaigns.name,
      (days.start)::date AS start,
      (count(*))::integer AS count,
      sum(round((((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2))::numeric, 2)) AS approximate_spend
     FROM (((( SELECT start.start,
              (start.start + '23:59:59'::interval) AS "end"
             FROM generate_series('2020-01-01 00:00:00'::timestamp without time zone, '2021-01-01 00:00:00'::timestamp without time zone, '1 day'::interval) start(start)) days
       JOIN adverts ON (((adverts.ad_creation_time >= days.start) AND (adverts.ad_creation_time <= days."end"))))
       JOIN funding_entities ON ((funding_entities.id = adverts.funding_entity_id)))
       JOIN campaigns ON ((campaigns.id = funding_entities.campaign_id)))
    GROUP BY days.start, campaigns.id
    ORDER BY campaigns.id;
  SQL
  create_view "ad_code_daily_summaries", materialized: true, sql_definition: <<-SQL
      SELECT (days.start)::date AS start,
      acvu.index,
      acvu.value,
      count(*) AS count,
      sum(((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2)) AS approximate_spend
     FROM ((( SELECT start.start,
              (start.start + '23:59:59'::interval) AS "end"
             FROM generate_series('2020-06-01 00:00:00+00'::timestamp with time zone, '2020-12-31 00:00:00+00'::timestamp with time zone, '1 day'::interval) start(start)) days
       JOIN adverts ON (((adverts.ad_creation_time >= days.start) AND (adverts.ad_creation_time <= days."end"))))
       JOIN ad_code_value_usages acvu ON ((adverts.id = acvu.advert_id)))
    WHERE (adverts.host_id IS NOT NULL)
    GROUP BY days.start, acvu.index, acvu.value
    ORDER BY (count(*)) DESC, days.start;
  SQL
  create_view "value_daily_summaries", materialized: true, sql_definition: <<-SQL
      SELECT daily_values.campaign_id,
      daily_values.campaign_slug,
      daily_values.index,
      daily_values.value,
      acvd.value_name,
      daily_values.start,
      daily_values.count,
      daily_values.approximate_spend
     FROM ((( SELECT campaigns.id AS campaign_id,
              campaigns.slug AS campaign_slug,
              u.index,
              u.value,
              (days.start)::date AS start,
              count(*) AS count,
              sum(round((((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2))::numeric, 2)) AS approximate_spend
             FROM ((((( SELECT start.start,
                      (start.start + '23:59:59'::interval) AS "end"
                     FROM generate_series('2020-07-01 00:00:00+00'::timestamp with time zone, '2021-01-01 00:00:00+00'::timestamp with time zone, '1 day'::interval) start(start)) days
               JOIN adverts ON (((adverts.ad_creation_time >= days.start) AND (adverts.ad_creation_time <= days."end"))))
               JOIN ad_code_value_usages u ON ((adverts.id = u.advert_id)))
               JOIN funding_entities ON ((funding_entities.id = adverts.funding_entity_id)))
               JOIN campaigns ON ((funding_entities.campaign_id = campaigns.id)))
            WHERE (adverts.host_id IS NOT NULL)
            GROUP BY campaigns.id, days.start, u.index, u.value
            ORDER BY (count(*)) DESC, days.start) daily_values
       JOIN ad_codes ON (((ad_codes.campaign_id = daily_values.campaign_id) AND (ad_codes.index = daily_values.index))))
       LEFT JOIN ad_code_value_descriptions acvd ON (((ad_codes.id = acvd.ad_code_id) AND ((acvd.value)::text = (daily_values.value)::text))));
  SQL
  create_view "wants_daily_summaries", materialized: true, sql_definition: <<-SQL
      SELECT (days.start)::date AS start,
      c.slug,
      adverts.wants_key,
      count(*) AS count,
      (sum(round((((adverts.spend_upper_bound + adverts.spend_lower_bound) / 2))::numeric, 2)))::bigint AS approximate_spend,
      round((((count(*))::numeric / sum(count(*)) OVER w_day) * (100)::numeric), 2) AS percentage
     FROM (((( SELECT start.start,
              (start.start + '23:59:59'::interval) AS "end"
             FROM generate_series('2020-07-01 00:00:00+00'::timestamp with time zone, '2020-12-31 00:00:00+00'::timestamp with time zone, '1 day'::interval) start(start)) days
       JOIN adverts ON (((adverts.ad_creation_time >= days.start) AND (adverts.ad_creation_time <= days."end"))))
       JOIN hosts h ON ((adverts.host_id = h.id)))
       JOIN campaigns c ON ((h.campaign_id = c.id)))
    GROUP BY c.slug, days.start, adverts.wants_key
    WINDOW w_day AS (PARTITION BY c.slug, ((days.start)::date));
  SQL
end
