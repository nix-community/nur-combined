#!/usr/bin/env bash

cd "$(dirname "$0")/.."

set -eu

function check_dependency() {
  if ! command -v "$1" &>/dev/null; then
    echo "error: missing dependency: $1"
    exit 1
  fi
}

check_dependency jq
check_dependency gron
check_dependency yaml2json

find test/ -name '*.yaml' | while read yaml_file; do

  expected="$(yaml2json < "$yaml_file" | jq -r)"

  actual="$(./bin/from-yaml.nix.sh "$yaml_file" | jq -r)"

  if [ "$actual" == "$expected" ]; then

    echo "ok $yaml_file"

  else

    echo "FAILED $yaml_file"
    diff -u \
      --label "actual $yaml_file" <(echo "$actual" | gron) \
      --label "expected $yaml_file" <(echo "$expected" | gron)

  fi

done
