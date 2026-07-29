#!/bin/bash
# Wrapper that replaces -Djps.kotlin.home with the kotlin-dist-for-ide-2.4.0 path.
# KOTLIN_DIST_PATH is substituted at build time by the Nix derivation.
NEWARGS=()
for arg in "$@"; do
  case "$arg" in
    -Djps.kotlin.home=*) NEWARGS+=("-Djps.kotlin.home=KOTLIN_DIST_PATH") ;;
    *) NEWARGS+=("$arg") ;;
  esac
done
exec "$REAL_JAVA" "${NEWARGS[@]}"
