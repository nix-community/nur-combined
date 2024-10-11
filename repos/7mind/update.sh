#!/usr/bin/env bash

rm result-*

curl -v -XPOST https://nur-update.nix-community.org/update\?repo\=7mind
