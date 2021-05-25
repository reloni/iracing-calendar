#!/bin/bash
set -e

CONTAINER_NAME=iRacing-portal-db

docker run --name $CONTAINER_NAME -p 5432:5432 -e POSTGRES_PASSWORD=123456 -d postgres:13.3-alpine