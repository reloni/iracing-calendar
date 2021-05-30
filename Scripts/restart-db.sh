#!/bin/bash
set -e

CONTAINER_NAME=iRacing-calendar-db

# docker run --name $CONTAINER_NAME -p 5432:5432 -e POSTGRES_PASSWORD=123456 -d postgres:13.3-alpine

docker rm -f $CONTAINER_NAME || true
export $(cat ./Sources/Api/.env | xargs)
docker run -d --rm --name $CONTAINER_NAME -h $CONTAINER_NAME \
        -e "POSTGRES_USER=${DATABASE_USERNAME}" -e "POSTGRES_PASSWORD=${DATABASE_PASSWORD}" -e "POSTGRES_HOST=${DATABASE_HOST}" \
        -e "POSTGRES_PORT=${DATABASE_PORT}" -e "POSTGRES_DB=${DATABASE_NAME}" -p 5432:5432 postgres:13.3-alpine