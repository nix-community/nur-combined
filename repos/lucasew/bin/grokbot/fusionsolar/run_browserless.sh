#!/usr/bin/env bash
# Daily FusionSolar collection via browserless on Nomad (no email). Usage: run_browserless.sh [YYYY-MM-DD]
set -u
D=${FUSIONSOLAR_DIR:-/workspace/bots/fusionsolar}; HERE=$(dirname "$(readlink -f "$0")"); DATE=${1:-$(date +%F)}; OUT=$D/out/$DATE; mkdir -p "$OUT"
set -a; . "${FUSIONSOLAR_ENV:-$HOME/.secrets/fusionsolar.env}"; set +a
TOK="$BROWSERLESS_TOKEN"
unset SENTRY_DSN BROWSERLESS_TOKEN SMTP_USER SMTP_PASSWD SMTP_PASSWORD SMTP_SERVER SMTP_DESTINATIONS SMTP_FROM
export TIMEOUT=10m OUT_DIR="$OUT" STATION_NAME="${STATION_NAME:?set STATION_NAME}"
LPORT=9222
read -r ADDR PORT < <(curl -s --socks5-hostname localhost:1055 ${NOMAD_ADDR:-http://ravenrock:4646}/v1/service/browserless | python3 -c 'import sys,json;s=json.load(sys.stdin)[0];print(s["Address"],s["Port"])')
[ -z "${PORT:-}" ] && { echo "browserless service not found" | tee -a "$OUT/run.log"; exit 2; }
echo "browserless at $ADDR:$PORT" | tee -a "$OUT/run.log"
pkill -f "socks_fwd.py $LPORT" 2>/dev/null
python3 "$HERE/socks_fwd.py" $LPORT "$ADDR" "$PORT" 1055 & FPID=$!; trap 'kill $FPID 2>/dev/null' EXIT; sleep 3
curl -sf -m 20 "http://127.0.0.1:$LPORT/json/version?token=$TOK" >/dev/null || echo "WARN: /json/version check failed" | tee -a "$OUT/run.log"
export BROWSER_CDP="ws://127.0.0.1:$LPORT?token=$TOK&timeout=600000"
BACKOFF=(0 30 120); rc=1
for n in 1 2 3; do
  sleep ${BACKOFF[$((n-1))]}
  echo "== attempt $n $(date)" | tee -a "$OUT/run.log"
  "${FUSIONSOLAR_BIN:-$D/fusionsolar-bot}" >>"$OUT/run.log" 2>&1; rc=$?
  echo "== attempt $n rc=$rc" | tee -a "$OUT/run.log"
  [ $rc -eq 0 ] && [ -s "$OUT/body.txt" ] && break
done
for f in "$OUT"/*.png; do [ -e "$f" ] && base64 -w0 "$f" > "${f%.png}.b64"; done
exit $rc
