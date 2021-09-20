#!/bin/bash
set -e

DB=iracingcalendardev
POSTGRES_ADMIN_USER=adminuser
POSTGRES_ADMIN_PASSWORD=123456
POSTGRES_API_USER=apiuserlocal
POSTGRES_API_PASSWORD=123456

./Scripts/restart-local-db.sh
sleep 5

cat ./sql/initialize-schema.sql \
  | sed 's/$DB/'"$DB"'/' \
  | sed 's/$USERNAME/'"$POSTGRES_API_USER"'/' \
  | sed 's/$PASSWORD/'"$POSTGRES_API_PASSWORD"'/' \
  > ./sql/initialize-schema-initialized.sql

psql --dbname=postgresql://${POSTGRES_ADMIN_USER}:${POSTGRES_ADMIN_PASSWORD}@localhost:5432/postgres \
    -f ./sql/initialize-schema-initialized.sql
./Scripts/migrate-db.sh local
psql --dbname=postgresql://${POSTGRES_API_USER}:${POSTGRES_API_PASSWORD}@localhost:5432/iracingcalendardev \
     -f ./sql/create-test-data.sql

rm ./sql/initialize-schema-initialized.sql