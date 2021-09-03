#!/bin/bash
set -e

DB=iracingcalendardev
POSTGRES_ADMIN_USER=adminuser
POSTGRES_ADMIN_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ArbitrraryBitsDatabaseAdminuserSecret --query SecretString --output text | jq -r ".password")
POSTGRES_API_USER=apiuserdev
POSTGRES_API_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ArbitrraryBitsDatabaseApiuserdevSecret --query SecretString --output text | jq -r ".password")

cat ./sql/initialize-schema.sql \
  | sed 's/$DB/'"$DB"'/' \
  | sed 's/$USERNAME/'"$POSTGRES_API_USER"'/' \
  | sed 's/$PASSWORD/'"$POSTGRES_API_PASSWORD"'/' \
  > ./sql/initialize-schema-initialized.sql

psql --dbname=postgresql://${POSTGRES_ADMIN_USER}:${POSTGRES_ADMIN_PASSWORD}@localhost:5432/postgres \
    -f ./sql/initialize-schema-initialized.sql
./Scripts/migrate-db.sh development
psql --dbname=postgresql://${POSTGRES_API_USER}:${POSTGRES_API_PASSWORD}@localhost:5432/iracingcalendardev \
     -f ./sql/create-test-data.sql

rm ./sql/initialize-schema-initialized.sql