DATABASE_URL?=postgres://localhost:5432/ads

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
	 text_search tsvector NULL, \
	 potential_reach json, \
	 publisher_platforms character varying[] \
); \
COPY tmp_adverts FROM STDIN DELIMITER ',' CSV HEADER; \
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

define UPDATE_IMPRESSIONS_SQL
		CREATE TEMPORARY TABLE tmp_impressions ( \
			 advert_id integer NOT NULL, \
			 lower_bound_spend integer NOT NULL, \
			 upper_bound_spend integer NOT NULL \
		); \
		COPY tmp_impressions FROM STDIN DELIMITER ',' CSV HEADER; \
			UPDATE adverts \
				SET spend_lower_bound = tmp_impressions.lower_bound_spend, \
						spend_upper_bound = tmp_impressions.upper_bound_spend \
				FROM tmp_impressions \
					WHERE adverts.id = tmp_impressions.advert_id; \
		DROP TABLE tmp_impressions;
endef

.PHONY: load-ads
load-ads: adverts.csv
	@echo "$(shell ruby -e "require 'csv'; puts CSV.read('$^').length - 1") records\n"
	cat $^ | psql ${DATABASE_URL} -Xc "${LOAD_ADS_SQL}"

MAX_ID=$(shell psql $(DATABASE_URL) -Xtc 'SELECT COALESCE(MAX(id), 0) FROM adverts')
adverts.csv:
	$(if ${ADS_PG_URL},,$(error must set ADS_PG_URL))
	@echo "Getting adverts with id over $(strip $(MAX_ID)) ...\n"
	@psql $(ADS_PG_URL) -Xc "COPY (SELECT * FROM adverts WHERE id > $(MAX_ID)) TO STDOUT DELIMITER ',' CSV HEADER;" > $@

##
# we must use ad_delivery_start_time as ad_creation_time is not indexed
IMPRESSIONS_FROM=2020-08-01
IMPRESSIONS_TO=2020-09-01
define ALL_IMPRESSIONS_FROM_SQL
	  SELECT DISTINCT ON (adverts.id) \
            adverts.id AS advert_id, \
            impressions.lower_bound_spend, \
            impressions.upper_bound_spend \
		FROM adverts \
		LEFT JOIN impressions ON adverts.id = impressions.advert_id \
		WHERE ad_delivery_start_time BETWEEN '$(IMPRESSIONS_FROM)' AND '$(IMPRESSIONS_TO)' \
		AND impressions.lower_bound_spend IS NOT NULL \
		AND funding_entity IN( \
				'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE', \
				'DONALD J. TRUMP FOR PRESIDENT, INC.', \
				'BIDEN FOR PRESIDENT', \
				'BIDEN VICTORY FUND', \
				'Biden for President' \
		) \
		ORDER BY adverts.id DESC, impressions.created_at DESC
endef

impressions.csv:
	@echo "Getting impressions between '$(IMPRESSIONS_FROM)' and '$(IMPRESSIONS_TO)' ...\n"
	psql $(ADS_PG_URL) -Xc "COPY (${ALL_IMPRESSIONS_FROM_SQL}) TO STDOUT DELIMITER ',' CSV HEADER;" > $@

.PHONY: update-impressions
update-impressions: impressions.csv
	@echo "Updating impressions ..."
	cat $^ | psql ${DATABASE_URL} -Xc "${UPDATE_IMPRESSIONS_SQL}"

.PHONY: clean
clean:
	- rm adverts.csv impressions.csv
