#!/usr/bin/env bash

pushd "$(git rev-parse --show-toplevel)" > /dev/null || exit 1
@script@
popd > /dev/null || exit 1
