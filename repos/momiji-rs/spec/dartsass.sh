#!/usr/bin/env bash
#
# dartsass.sh — a SASS_BIN-compatible wrapper around dart-sass via npx.
#
# Used ONLY to validate the harness itself: a correct sass implementation
# should score ~100% on the attempted (non-skipped) cases. If it doesn't,
# our normalization/comparison is wrong.
#
# Contract expected by run_spec.py's SASS_BIN:
#   <bin> [--style=expanded|compressed] <input-file>   -> CSS on stdout
#   deprecation/other warnings go to stderr (we capture stdout only).
#
# DART_SASS_VERSION pins the package: unset, npx resolves whatever is current,
# which is fine for validating the harness but NOT for generating an oracle.
# spec/gen_compressed.py sets it to the pinned version for that reason.
#
# --no-source-map keeps stdout pure CSS.
exec npx --yes "sass${DART_SASS_VERSION:+@$DART_SASS_VERSION}" \
    --no-source-map "$@"
