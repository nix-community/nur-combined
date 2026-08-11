#! /usr/bin/env bash

cd "$(dirname "$0")"

repo=https://github.com/piuccio/cowsay

# https://github.com/piuccio/cowsay/tags
version=v1.5.0

wget -N \
  $repo/raw/$version/package.json \
  $repo/raw/$version/package-lock.json
