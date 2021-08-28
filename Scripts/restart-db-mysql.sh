#!/bin/bash
set -e

CONTAINER_NAME=iRacing-calendar-db-mysql

docker rm -f $CONTAINER_NAME || true

docker run -d \
--platform linux/x86_64 \
--name $CONTAINER_NAME -h $CONTAINER_NAME \
-e MYSQL_ROOT_PASSWORD=root-password \
-p 3306:3306 mysql:5.7.35