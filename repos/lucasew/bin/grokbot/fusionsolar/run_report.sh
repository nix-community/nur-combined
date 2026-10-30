#!/usr/bin/env bash
# Daily FusionSolar report runner. Usage: run_report.sh [destinations]
set -u
D=${FUSIONSOLAR_DIR:-/workspace/bots/fusionsolar}; HERE=$(dirname "$(readlink -f "$0")")
DATE=$(date +%F); OUT=$D/out/$DATE; mkdir -p "$OUT"
set -a; . "${FUSIONSOLAR_ENV:-$HOME/.secrets/fusionsolar.env}"; set +a
export SMTP_PASSWD="${SMTP_PASSWD:-$SMTP_PASSWORD}"
[ -n "${1:-}" ] && export SMTP_DESTINATIONS="$1"
unset SENTRY_DSN BROWSERLESS_TOKEN
export TIMEOUT=10m OUT_DIR="$OUT"
CHROME_PROXY="${CHROME_PROXY:-http://127.0.0.1:8791}"  # alt: socks5://localhost:1055
PORT=9333; PROF=$(mktemp -d)
start_chrome(){ rm -rf "$PROF"; PROF=$(mktemp -d)
  google-chrome --headless=new --no-sandbox --disable-gpu --proxy-server="$CHROME_PROXY" --proxy-bypass-list="localhost;127.0.0.1;[::1]" --remote-debugging-port=$PORT --user-data-dir="$PROF" about:blank >"$OUT/chrome.log" 2>&1 & CPID=$!
  for i in $(seq 30); do WS=$(curl -s localhost:$PORT/json/version | python3 -c 'import sys,json;print(json.load(sys.stdin)["webSocketDebuggerUrl"])' 2>/dev/null) && [ -n "$WS" ] && break; sleep 1; done
  export BROWSER_CDP="$WS"; }
stop_chrome(){ kill $CPID 2>/dev/null; sleep 2; kill -9 $CPID 2>/dev/null; pkill -f "remote-debugging-port=$PORT" 2>/dev/null; }
BACKOFF=(0 30 120); rc=1
for n in 1 2 3; do
  sleep ${BACKOFF[$((n-1))]}
  echo "== attempt $n $(date)" | tee -a "$OUT/run.log"
  start_chrome
  "${FUSIONSOLAR_BIN:-$D/fusionsolar-bot}" >>"$OUT/run.log" 2>&1; rc=$?
  stop_chrome
  echo "== attempt $n rc=$rc" | tee -a "$OUT/run.log"
  [ $rc -eq 0 ] && break
done
rm -rf "$PROF"; exit $rc
