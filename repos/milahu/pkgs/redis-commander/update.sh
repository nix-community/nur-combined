#! /usr/bin/env bash

cd "$(dirname "$0")"

rev=4bb60a06660e4c55f0e9c46f1d3a9ce6b1bee6ef

wget -N https://github.com/joeferner/redis-commander/raw/$rev/package.json
wget -N https://github.com/joeferner/redis-commander/raw/$rev/package-lock.json
