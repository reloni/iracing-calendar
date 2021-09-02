#!/bin/bash
set -e

psql -h localhost -U adminuser -d postgres -f ./sql/initialize-schema.sql
./Scripts/migrate-db-local.sh
psql -h localhost -U apiuser -d iracingcalendardev -f ./sql/create-test-data.sql