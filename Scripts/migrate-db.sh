#!/bin/bash
set -e

ENV=$1

lsof -i :8000 -sTCP:LISTEN \
    | awk 'NR > 1 {print $2}' \
    | xargs kill -15 \
    && (cd ./Sources/Api && swift run Api migrate --env $ENV --log debug)