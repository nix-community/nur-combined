#!/usr/bin/env bash
# Build the sasso-napi addon and stage it as npm/sasso.node for the local
# platform. (Publishing needs a per-platform prebuild matrix — out of scope;
# this staging serves the in-repo tests and the bench/asyncify harness.)
set -euo pipefail
cd "$(dirname "$0")"

cargo build --release

case "$(uname -s)" in
  Darwin) lib="target/release/libsasso_napi.dylib" ;;
  Linux)  lib="target/release/libsasso_napi.so" ;;
  *)      echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

cp "$lib" npm/sasso.node
sz=$(wc -c <npm/sasso.node)
printf '>> staged %s -> npm/sasso.node (%s bytes)\n' "$lib" "$sz"
