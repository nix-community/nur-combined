#!/usr/bin/env bash

cd "$(dirname "$0")"

wget -N \
  https://github.com/milahu/gittorrent/raw/master/package.json \
  https://github.com/milahu/gittorrent/raw/master/package-lock.json \
