#! /usr/bin/env bash

cd "$(dirname "$0")"

wget -N \
  https://github.com/milahu/pnpm-install-only/raw/master/package.json \
  https://github.com/milahu/pnpm-install-only/raw/master/package-lock.json \
