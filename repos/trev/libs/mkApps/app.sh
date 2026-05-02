#!/usr/bin/env bash

pushd "$(git rev-parse --show-toplevel)" || exit 1
@script@
popd || exit 1
