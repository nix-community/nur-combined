#!/usr/bin/env bash
# Mint a short-lived signed URL for the qq CDN. Reads a URL ($1 or stdin),
# prints the signed URL; if signing fails, prints the URL unchanged.
set -euo pipefail

URL="${1:-$(cat)}"
[ -n "${URL:-}" ] || { echo "usage: sign-url.sh <url>" >&2; exit 1; }

if ! command -v jq >/dev/null 2>&1; then
  echo "sign-url.sh: jq is required to parse the GetSign response" >&2
  exit 1
fi

SIGNED="$(curl -sS --max-time 20 -X POST \
  'https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign' \
  -H 'Content-Type: application/json' \
  -H 'x-oidb: {"uint32_command":"0x9b8e","uint32_service_type":1}' \
  --data "{\"url\":\"$URL\"}" \
  | jq -r '.data.url // empty')"

if [ -n "${SIGNED:-}" ]; then
  printf '%s\n' "$SIGNED"
else
  printf '%s\n' "$URL"
fi
