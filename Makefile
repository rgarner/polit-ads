OWNER_DB=postgres
DATABASE_NAME=ads
SCHEMA_URL=postgresql://localhost:5432/ads

define LOAD_ADS_SQL
CREATE TEMPORARY TABLE tmp_adverts ( \
	 id integer NOT NULL, \
	 page_id character varying(25) NOT NULL, \
	 page_name text NULL, \
	 post_id character varying(25) NOT NULL, \
	 country character varying(10) NOT NULL, \
	 ad_creation_time timestamp with time zone NULL, \
	 ad_creative_body text NULL, \
	 ad_creative_link_caption text NULL, \
	 ad_creative_link_description text NULL, \
	 ad_creative_link_title text NULL, \
	 ad_delivery_start_time timestamp with time zone NULL, \
	 ad_delivery_stop_time timestamp with time zone NULL, \
	 ad_snapshot_url text NULL, \
	 image_link text NULL, \
	 currency character varying(10) NULL, \
	 funding_entity text NULL, \
	 created_at timestamp with time zone NULL, \
	 updated_at timestamp with time zone NULL, \
	 ad_info character varying NULL, \
	 text_search tsvector NULL \
); \
COPY tmp_adverts FROM '$(abspath adverts.csv)' DELIMITER ',' CSV HEADER; \
INSERT INTO adverts ( \
	 id, \
	 page_id, \
	 page_name, \
	 post_id, \
	 country, \
	 ad_creation_time, \
	 ad_creative_body, \
	 ad_creative_link_caption, \
	 ad_creative_link_description, \
	 ad_creative_link_title, \
	 ad_delivery_start_time, \
	 ad_delivery_stop_time, \
	 ad_snapshot_url, \
	 image_link, \
	 currency, \
	 funding_entity, \
	 created_at, \
	 updated_at, \
	 ad_info, \
	 text_search \
) SELECT \
	 id, \
	 page_id, \
	 page_name, \
	 post_id, \
	 country, \
	 ad_creation_time, \
	 ad_creative_body, \
	 ad_creative_link_caption, \
	 ad_creative_link_description, \
	 ad_creative_link_title, \
	 ad_delivery_start_time, \
	 ad_delivery_stop_time, \
	 ad_snapshot_url, \
	 image_link, \
	 currency, \
	 funding_entity, \
	 created_at, \
	 updated_at, \
	 ad_info, \
	 text_search \
FROM tmp_adverts \
ON CONFLICT ON CONSTRAINT adverts_pkey \
DO NOTHING; \
DROP TABLE tmp_adverts;
endef

.PHONY: load-ads
load-ads: adverts.csv
	psql ${DATABASE_NAME} -c "${LOAD_ADS_SQL}"

adverts.csv:
	$(if ${ADS_PG_URL},,$(error must set ADS_PG_URL))
	psql $(ADS_PG_URL) -X -c "COPY adverts TO STDOUT DELIMITER ',' CSV HEADER;" > $@