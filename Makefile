OWNER_DB=postgres
DATABASE_NAME=ads

adverts.csv:	
	$(if ${ADS_PG_URL},,$(error must set ADS_PG_URL))
	psql $(ADS_PG_URL) -c "COPY adverts TO STDOUT DELIMITER ',' CSV HEADER;" > $@

.PHONY: load-ads
load-ads: adverts.csv
	psql ${DATABASE_NAME} -c "COPY adverts FROM '$(abspath adverts.csv)' DELIMITER ',' CSV HEADER;"


