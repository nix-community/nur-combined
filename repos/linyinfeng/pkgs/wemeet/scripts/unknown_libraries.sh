#!/usr/bin/env bash

DIR="$(dirname "$(realpath "$0")")"

fd "$@" --exec "$DIR/check_one.sh" '{/}'
