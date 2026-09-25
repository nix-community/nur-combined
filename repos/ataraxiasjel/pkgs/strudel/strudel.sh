#!/usr/bin/env bash
# Serves the packaged Strudel static site on localhost and optionally
# opens it in the default browser.
set -euo pipefail

port="${STRUDEL_PORT:-4321}"
open=0

usage() {
  cat <<EOF
Usage: strudel [--port N] [--open] [-h|--help]

Serves the Strudel live-coding environment (static site from
\$STRUDEL_ROOT) on http://127.0.0.1:<port>/.

  --port N, -p N   port to listen on (default: 4321, env STRUDEL_PORT)
  --open           open the URL in the default browser (xdg-open)
  -h, --help       show this help
EOF
}

while (($# > 0)); do
  case "$1" in
    --port | -p)
      port="${2:?missing port number}"
      shift 2
      ;;
    --open)
      open=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "strudel: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

root="${STRUDEL_ROOT:?STRUDEL_ROOT is not set}"
url="http://127.0.0.1:${port}/"

echo "Serving Strudel at ${url} (root: ${root})"
if ((open)); then
  # Give the server a moment to bind, then open the browser in background.
  (sleep 1; xdg-open "${url}" >/dev/null 2>&1 &) &>/dev/null || true
fi

# COOP/COEP headers mirror the upstream astro dev server config and are
# required for SharedArrayBuffer (dough/superdoough sample engine).
exec miniserve \
  -i 127.0.0.1 \
  -p "${port}" \
  --title Strudel \
  --index index.html \
  --header "Cross-Origin-Opener-Policy: same-origin" \
  --header "Cross-Origin-Embedder-Policy: credentialless" \
  -F \
  "${root}"
