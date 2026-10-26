#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
script="$source_dir/openconnect-auto.sh"
temporary=$(mktemp -d)
trap 'if [[ ${KEEP_TEST_TMP:-} == true ]]; then printf "Fixtures: %s\n" "$temporary"; else rm -rf "$temporary"; fi' EXIT
export MOCK_ROOT="$temporary/mock" XDG_STATE_HOME="$temporary/state"
mkdir -p "$MOCK_ROOT/bin"
export PATH="$MOCK_ROOT/bin:$PATH"
printf '#!%s\n' "$(command -v bash)" >"$MOCK_ROOT/bin/buf"
cat >>"$MOCK_ROOT/bin/buf" <<'MOCK'
set -euo pipefail
for argument; do
  [[ $argument != *fixture-api-value* && $argument != *fixture-cookie* ]] || exit 9
done
while IFS= read -r header && [[ -n $header ]]; do :; done
body=$(cat)
if [[ -f $MOCK_ROOT/restarting ]]; then printf '{}\n'; exit 0; fi
if [[ -f $MOCK_ROOT/rpc-unknown ]]; then exit 16; fi
method=${!#}; method=${method##*/}
case $method in
SubscribeGroups)
  if [[ -f $MOCK_ROOT/groups.json ]]; then cat "$MOCK_ROOT/groups.json"; exit 32; fi
  target='Test VPN'
  [[ ! -f $MOCK_ROOT/direct ]] || target=Direct
  jq -cn --arg target "$target" '{group: [{tag: "Egress", selected: "Nested"}, {tag: "Nested", selected: $target}]}'
  exit 32 ;;
SubscribeOpenConnectStatus)
  state=auth-pending; id=challenge-1
  [[ ! -f $MOCK_ROOT/submitted ]] || state=connected
  [[ ! -f $MOCK_ROOT/changed ]] || id=challenge-2
  if [[ -f $MOCK_ROOT/waiting ]]; then printf '{"endpoints":[{"endpointTag":"Test VPN","state":"connecting"}]}\n'; exit 32; fi
  jq -cn --arg state "$state" --arg id "$id" '{endpoints: [{endpointTag: "Test VPN", state: $state, authChallenge:
    (if $state == "connected" then null else {id: $id, browser: {url: "https://vpn.example.test/", cookieNames: ["Session", "Token"]}} end)}]}'
  exit 32 ;;
SubmitOpenConnectAuthResponse)
  printf '%s' "$body" | jq -e '.challengeID == "challenge-1" and .endpointTag == "Test VPN" and (.browser | has("finalURL") | not)
    and (.browser.cookies | map(.name) == ["Session", "Token"])' >/dev/null
  touch "$MOCK_ROOT/submitted"
  printf '{}\n' ;;
CancelOpenConnectAuthChallenge) touch "$MOCK_ROOT/canceled"; printf '{}\n' ;;
SelectOutbound)
  printf '%s' "$body" | jq -r '[.groupTag,.outboundTag] | @json' >> "$MOCK_ROOT/choices"
  jq --argjson body "$body" '(.group[] | select(.tag == $body.groupTag) | .selected) = $body.outboundTag' "$MOCK_ROOT/groups.json" > "$MOCK_ROOT/groups.tmp"
  mv "$MOCK_ROOT/groups.tmp" "$MOCK_ROOT/groups.json"
  printf '{}\n' ;;
*) exit 96 ;;
esac
MOCK
printf '#!%s\n' "$(command -v bash)" >"$MOCK_ROOT/bin/curl"
cat >>"$MOCK_ROOT/bin/curl" <<'MOCK'
set -euo pipefail
cat > /dev/null
for argument; do [[ $argument != *fixture-api-value* ]] || exit 9; done
if [[ -f $MOCK_ROOT/manual-during-probe ]]; then
  jq '(.group[] | select(.tag == "jaist") | .selected) = "Second exit"' "$MOCK_ROOT/groups.json" > "$MOCK_ROOT/groups.tmp"
  mv "$MOCK_ROOT/groups.tmp" "$MOCK_ROOT/groups.json"
fi
case ${!#} in
  */proxies/First%20exit/delay*) [[ -f $MOCK_ROOT/mesh-1 ]] || exit 22 ;;
  */proxies/Second%20exit/delay*) [[ -f $MOCK_ROOT/mesh-2 ]] || exit 22 ;;
  */proxies/Test%20VPN/delay*) [[ ! -f $MOCK_ROOT/vpn-unhealthy ]] || exit 22 ;;
  *) exit 9 ;;
esac
printf '{"delay":15}\n'
MOCK
printf '#!%s\n' "$(command -v bash)" >"$MOCK_ROOT/bin/authenticate"
cat >>"$MOCK_ROOT/bin/authenticate" <<'MOCK'
set -euo pipefail
touch "$MOCK_ROOT/started"
jq -e '.username == "fixture-user" and .password == "fixture-password" and .certificate.pfxBase64 == "YWJj"' <&3 >/dev/null
if [[ -f $MOCK_ROOT/reject ]]; then printf 'rejected: fixture-password must stay private\n' >&2; exit 1; fi
if [[ -f $MOCK_ROOT/network ]]; then printf 'network: fixture-password must stay private\n' >&2; exit 1; fi
if [[ -f $MOCK_ROOT/change ]]; then touch "$MOCK_ROOT/changed"; fi
if [[ -f $MOCK_ROOT/malformed ]]; then printf '{"gateway":"https://vpn.example.test/","cookies":{"Session":"invalid;cookie","Token":"fixture-cookie-token"}}\n'; exit 0; fi
if [[ -f $MOCK_ROOT/slow ]]; then sleep 30; fi
printf '{"gateway":"https://vpn.example.test/","cookies":{"Session":"fixture-cookie-session","Token":"fixture-cookie-token"}}\n'
MOCK
chmod +x "$MOCK_ROOT/bin/"*
jq -n --arg provider "$MOCK_ROOT/bin/authenticate" '{
  endpoint: "Test VPN", apiURL: "http://127.0.0.1:9091", gateway: "https://vpn.example.test/", selectors: ["Egress"], pollSeconds: 1,
  apiSecretCommand: ["printf", "fixture-api-value"], authCommands: {certificate: [$provider]},
  credentials: [
    {path: ["username"], command: ["printf", "fixture-user"]},
    {path: ["password"], command: ["printf", "fixture-password"]},
    {path: ["certificate", "pfxBase64"], encoding: "gopass-base64", command: ["printf", "Content-Transfer-Encoding: base64\nContent-Disposition: attachment\n\nYWJj\n"]}
  ]
}' >"$temporary/config.json"
run() { bash "$script" --config "$temporary/config.json" "$@" >"$temporary/output" 2>&1; }
expect() {
  local expected=$1 code=0
  shift
  run "$@" || code=$?
  if ((code != expected)); then
    printf 'Expected %s, received %s: %s\n' "$expected" "$code" "$*"
    cat "$temporary/output"
    exit 1
  fi
}
reset() {
  rm -rf "$XDG_STATE_HOME"
  rm -f "$MOCK_ROOT/"{started,submitted,direct,changed,change,reject,network,canceled,slow,malformed,restarting,rpc-unknown}
}

jq -en -L "$source_dir" 'include "auth";
  ([{tag:"a", selected:"b"}, {tag:"b", selected:"a"}] | selected(["a"]; "vpn") | not)
  and ([{tag:"a", selected:"vpn"}] | selected(["a"]; "vpn"))
  and ("Content-Transfer-Encoding: base64\r\n\r\nYWJj\r\n" | credential("gopass-base64")) == "YWJj"' >/dev/null
printf 'ok - selector chains, cycles and binary-entry decoding\n'
expect 0 status
[[ ! -e $MOCK_ROOT/started ]]
touch "$MOCK_ROOT/direct"
expect 0 watch --once
[[ ! -e $MOCK_ROOT/started ]]
printf 'ok - unselected VPN does not read credentials or authenticate\n'
reset
touch "$MOCK_ROOT/restarting"
expect 75 watch --once
[[ -z $(ls "$XDG_STATE_HOME/openconnect-auto/"*/paused 2>/dev/null || true) && ! -f $MOCK_ROOT/started ]]
rm "$MOCK_ROOT/restarting"
touch "$MOCK_ROOT/rpc-unknown"
expect 75 watch --once
[[ -z $(ls "$XDG_STATE_HOME/openconnect-auto/"*/paused 2>/dev/null || true) && ! -f $MOCK_ROOT/started ]]
printf 'ok - restarting APIs and transient RPC failures never pause authentication\n'
reset
expect 0 watch --once
[[ -f $MOCK_ROOT/submitted ]]
expect 0 watch --once
printf 'ok - selected VPN authenticates and reuses its session\n'
reset
expect 0 cancel
[[ -f $MOCK_ROOT/canceled ]]
expect 0 watch --once
[[ ! -e $MOCK_ROOT/started ]]
expect 0 login
[[ -f $MOCK_ROOT/submitted ]]
printf 'ok - cancel pauses persistently; manual login resumes\n'
reset
touch "$MOCK_ROOT/reject"
expect 65 watch --once
rm "$MOCK_ROOT/reject" "$MOCK_ROOT/started"
expect 0 watch --once
[[ ! -e $MOCK_ROOT/started ]]
printf 'ok - rejected credentials pause without an automatic retry\n'
reset
touch "$MOCK_ROOT/network"
expect 75 watch --once
[[ -z $(ls "$XDG_STATE_HOME/openconnect-auto/"*/paused 2>/dev/null || true) ]]
rm "$MOCK_ROOT/network"
expect 0 watch --once
printf 'ok - network failures remain retryable\n'
reset
touch "$MOCK_ROOT/change"
expect 75 watch --once
[[ ! -e $MOCK_ROOT/submitted ]]
printf 'ok - a stale authentication challenge is never submitted\n'
reset
touch "$MOCK_ROOT/malformed"
expect 65 watch --once
[[ ! -e $MOCK_ROOT/submitted ]]
printf 'ok - invalid cookie values are rejected before submission\n'
reset
expect 0 status
lock=$(ls -d "$XDG_STATE_HOME/openconnect-auto/"*)/auth.lock
mkdir "$lock"
printf '999999999\n' >"$lock/pid"
expect 0 login
printf 'ok - a dead process lock is recovered\n'
reset
touch "$MOCK_ROOT/slow"
bash "$script" --config "$temporary/config.json" watch --once >"$temporary/output" 2>&1 &
watcher=$!
for ((attempt = 0; attempt < 100; attempt++)); do
  [[ ! -f $MOCK_ROOT/started ]] || break
  sleep 0.1
done
[[ -f $MOCK_ROOT/started ]]
expect 73 login
touch "$MOCK_ROOT/direct"
code=0
wait "$watcher" || code=$?
[[ $code == 130 && ! -e $MOCK_ROOT/submitted ]]
printf 'ok - concurrent login is excluded; switching away cancels authentication\n'
reset
touch "$MOCK_ROOT/slow"
bash "$script" --config "$temporary/config.json" watch --once >"$temporary/output" 2>&1 &
watcher=$!
for ((attempt = 0; attempt < 100; attempt++)); do
  [[ ! -f $MOCK_ROOT/started ]] || break
  sleep 0.1
done
[[ -f $MOCK_ROOT/started ]]
kill -TERM "$watcher"
code=0
wait "$watcher" || code=$?
[[ $code == 143 && ! -e $MOCK_ROOT/submitted ]]
[[ -z $(ls -d "$XDG_STATE_HOME/openconnect-auto/"*/auth.lock 2>/dev/null || true) ]]
printf 'ok - terminating the service releases the login lock\n'
bash "$source_dir/fallback-tests.sh" "$temporary/config.json"
if rg -q 'fixture-password|fixture-cookie|fixture-api-value' "$XDG_STATE_HOME" "$temporary/output"; then
  printf 'Sensitive fixture data leaked\n'
  exit 1
fi
printf 'ok - state and diagnostics contain no credentials or cookies\n'
