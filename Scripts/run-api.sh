#!/bin/bash
set -e

lsof -i :8000 -sTCP:LISTEN \
    | awk 'NR > 1 {print $2}' \
    | xargs kill -15 \
    && export $(cat ./Sources/Api/.env | xargs) \
    && (cd ./Sources/Api && swift run Api serve --port 8000 --env development --log debug)