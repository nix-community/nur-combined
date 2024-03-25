#!/usr/bin/env bash

cd "$(dirname "$0")"

wget -N \
  https://github.com/aclap-dev/vdhcoapp/raw/master/app/package.json \
  https://github.com/aclap-dev/vdhcoapp/raw/master/app/package-lock.json \
