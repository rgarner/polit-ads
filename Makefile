OWNER_DB=postgres
DATABASE_NAME=ads

adverts.csv:	
	$(if ${ADS_PG_URL},,$(error must set ADS_PG_URL))
	psql $(ADS_PG_URL) -c "COPY adverts TO STDOUT DELIMITER ',' CSV HEADER;" > $@

.PHONY: db-reset
db-reset: db-drop db-create db-schema-load

.PHONY: db-drop
db-drop:
	psql ${OWNER_DB} -c "DROP DATABASE ${DATABASE_NAME};"	

.PHONY: db-create
db-create:
	psql ${OWNER_DB} -c "CREATE DATABASE ${DATABASE_NAME};"

.PHONY: db-schema-load
db-schema-load:	
	psql ${DATABASE_NAME} < schema.sql

.PHONY: load-ads
load-ads: adverts.csv
	psql ${DATABASE_NAME} -c "COPY adverts FROM '$(abspath adverts.csv)' DELIMITER ',' CSV HEADER;"


