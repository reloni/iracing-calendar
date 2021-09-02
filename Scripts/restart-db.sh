#!/bin/bash
set -e

CONTAINER_NAME=iRacing-calendar-db

docker rm -f $CONTAINER_NAME || true

docker run -d \
       --name $CONTAINER_NAME -h $CONTAINER_NAME \
        -e "POSTGRES_USER=adminuser" -e "POSTGRES_PASSWORD=123456" -e "POSTGRES_HOST=localhost" \
        -e "POSTGRES_PORT=5432" -e "POSTGRES_DB=initialdb" -p 5432:5432 postgres:13.3-alpine