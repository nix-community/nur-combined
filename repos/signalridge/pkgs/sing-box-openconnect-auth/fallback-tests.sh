#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
script="$source_dir/openconnect-auto.sh"
configuration="$MOCK_ROOT/fallback.json"
jq '.selectors = ["Egress", "jaist"] | .clashAPIURL = "http://127.0.0.1:9090" | .fallbackPollSeconds = 1
  | .fallbacks = [{parent:"jaist", selector:"jaist auto", preferred:["First exit","Second exit"], fallback:"Egress", probeURL:"https://vpn.example.test/check"}]' "$1" >"$configuration"
reset() {
  rm -rf "$XDG_STATE_HOME"
  rm -f "$MOCK_ROOT/"{started,submitted,changed,change,reject,network,canceled,slow,malformed,waiting,mesh-1,mesh-2,vpn-unhealthy,manual-during-probe,choices}
  jq -n '{group:[{tag:"jaist",selected:"First exit"},{tag:"jaist auto",selected:"First exit"},{tag:"Egress",selected:"Direct"}]}' >"$MOCK_ROOT/groups.json"
}
run() {
  local expected=$1 code=0
  shift
  bash "$script" --config "$configuration" "$@" >"$MOCK_ROOT/fallback-output" 2>&1 || code=$?
  if ((code != expected)); then
    printf 'Fallback expected %s, got %s\n' "$expected" "$code"
    cat "$MOCK_ROOT/fallback-output"
    exit 1
  fi
}
choice() { jq -er --arg tag "$1" '.group[] | select(.tag == $tag) | .selected' "$MOCK_ROOT/groups.json"; }
choose() {
  jq --arg tag "$1" --arg selected "$2" '(.group[] | select(.tag == $tag) | .selected) = $selected' "$MOCK_ROOT/groups.json" >"$MOCK_ROOT/groups.tmp"
  mv "$MOCK_ROOT/groups.tmp" "$MOCK_ROOT/groups.json"
}
reset
touch "$MOCK_ROOT/mesh-1" "$MOCK_ROOT/mesh-2"
run 0 watch --once
[[ $(choice jaist) == 'jaist auto' && $(choice 'jaist auto') == 'First exit' && ! -f $MOCK_ROOT/started ]]
rm "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice 'jaist auto') == 'Second exit' && ! -f $MOCK_ROOT/started ]]
printf 'ok - fallback migrates existing automatic choices and preserves priority\n'
rm "$MOCK_ROOT/mesh-2"
run 0 watch --once
[[ $(choice 'jaist auto') == 'Test VPN' && -f $MOCK_ROOT/submitted ]]
run 0 watch --once
touch "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice 'jaist auto') == 'First exit' ]]
printf 'ok - cold VPN authentication and recovery to the first preferred exit\n'
choose jaist 'Test VPN'
run 0 watch --once
[[ $(choice jaist) == 'Test VPN' && $(choice 'jaist auto') == 'First exit' ]]
choose jaist 'Second exit'
run 0 watch --once
[[ $(choice jaist) == 'Second exit' ]]
printf 'ok - explicit manual selections are not overwritten\n'
reset
touch "$MOCK_ROOT/reject"
run 65 watch --once
[[ $(choice 'jaist auto') == Egress ]]
rm "$MOCK_ROOT/reject" "$MOCK_ROOT/started"
run 0 watch --once
[[ ! -f $MOCK_ROOT/started && $(choice 'jaist auto') == Egress ]]
touch "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice 'jaist auto') == 'First exit' ]]
printf 'ok - rejected authentication retreats and pauses; mesh recovery still works\n'
reset
touch "$MOCK_ROOT/network"
run 75 watch --once
[[ $(choice 'jaist auto') == Egress ]]
rm "$MOCK_ROOT/network" "$MOCK_ROOT/started"
run 0 watch --once
[[ ! -f $MOCK_ROOT/started && $(choice 'jaist auto') == Egress ]]
run 0 login
run 0 watch --once
[[ $(choice 'jaist auto') == 'Test VPN' ]]
printf 'ok - retry cooldown survives restarts; manual login resumes immediately\n'
reset
touch "$MOCK_ROOT/submitted" "$MOCK_ROOT/vpn-unhealthy"
run 0 watch --once
[[ $(choice 'jaist auto') == Egress && ! -f $MOCK_ROOT/started ]]
rm "$MOCK_ROOT/vpn-unhealthy"
run 0 watch --once
[[ $(choice 'jaist auto') == Egress ]]
printf 'ok - a connected but unusable VPN also falls back with cooldown\n'
reset
touch "$MOCK_ROOT/waiting"
run 75 watch --once
[[ $(choice 'jaist auto') == 'Test VPN' && ! -f $MOCK_ROOT/started ]]
metadata=$(ls "$XDG_STATE_HOME/openconnect-auto/"*/fallback-*.json)
jq '.pendingSince = 1' "$metadata" >"$MOCK_ROOT/metadata.tmp"
mv "$MOCK_ROOT/metadata.tmp" "$metadata"
run 0 watch --once
[[ $(choice 'jaist auto') == Egress && ! -f $MOCK_ROOT/started ]]
printf 'ok - pending authentication gets a grace period and then a bounded fallback\n'
reset
touch "$MOCK_ROOT/manual-during-probe"
run 0 watch --once
[[ $(choice jaist) == 'Second exit' && $(choice 'jaist auto') == 'First exit' && ! -f $MOCK_ROOT/started ]]
printf 'ok - manual changes during health probes win over automatic selection\n'
reset
choose jaist 'Second exit'
touch "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice jaist) == 'jaist auto' ]]
choose jaist 'Second exit'
run 0 watch --once
[[ $(choice jaist) == 'Second exit' ]]
printf 'ok - old automatic-choice migration runs only once\n'
reset
touch "$MOCK_ROOT/slow"
bash "$script" --config "$configuration" watch --once >"$MOCK_ROOT/fallback-background" 2>&1 &
watcher=$!
for ((attempt = 0; attempt < 100; attempt++)); do
  [[ ! -f $MOCK_ROOT/started ]] || break
  sleep 0.1
done
[[ -f $MOCK_ROOT/started ]]
run 73 watch --once
[[ $(choice 'jaist auto') == 'Test VPN' ]]
choose jaist 'Second exit'
code=0
wait "$watcher" || code=$?
[[ $code == 130 ]]
printf 'ok - fallback selection and authentication share a process lock\n'
reset
touch "$MOCK_ROOT/slow"
jq '.fallbackAuthSeconds = 1' "$configuration" >"$MOCK_ROOT/config.tmp"
mv "$MOCK_ROOT/config.tmp" "$configuration"
run 75 watch --once
[[ $(choice 'jaist auto') == Egress && ! -f $MOCK_ROOT/submitted ]]
printf 'ok - authentication is canceled when its fallback grace deadline expires\n'
jq '.fallbackAuthSeconds = 240 | .fallbacks[0].selector = "jaist" | del(.fallbacks[0].parent)' "$configuration" >"$MOCK_ROOT/config.tmp"
mv "$MOCK_ROOT/config.tmp" "$configuration"
reset_flat() {
  reset
  jq '.group |= map(select(.tag != "jaist auto"))' "$MOCK_ROOT/groups.json" >"$MOCK_ROOT/groups.tmp"
  mv "$MOCK_ROOT/groups.tmp" "$MOCK_ROOT/groups.json"
}
reset_flat
touch "$MOCK_ROOT/mesh-1" "$MOCK_ROOT/mesh-2"
run 0 watch --once
[[ $(choice jaist) == 'First exit' && ! -f $MOCK_ROOT/started ]]
rm "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice jaist) == 'Second exit' && ! -f $MOCK_ROOT/started ]]
rm "$MOCK_ROOT/mesh-2"
run 0 watch --once
[[ $(choice jaist) == 'Test VPN' && -f $MOCK_ROOT/submitted ]]
touch "$MOCK_ROOT/mesh-1"
run 0 watch --once
[[ $(choice jaist) == 'First exit' ]]
printf 'ok - flat selector updates the actual UI choice and recovers automatically\n'
choose jaist 'Test VPN'
run 0 watch --once
run 0 watch --once
[[ $(choice jaist) == 'Test VPN' ]]
printf 'ok - an explicitly selected VPN is preserved in flat mode\n'
reset_flat
touch "$MOCK_ROOT/network"
run 75 watch --once
[[ $(choice jaist) == Egress ]]
rm "$MOCK_ROOT/network" "$MOCK_ROOT/started"
run 0 watch --once
[[ $(choice jaist) == Egress && ! -f $MOCK_ROOT/started ]]
touch "$MOCK_ROOT/mesh-2"
run 0 watch --once
[[ $(choice jaist) == 'Second exit' ]]
printf 'ok - flat fallback cooldown and preferred-exit recovery survive restart\n'
reset_flat
touch "$MOCK_ROOT/reject"
run 65 watch --once
[[ $(choice jaist) == Egress ]]
rm "$MOCK_ROOT/reject" "$MOCK_ROOT/started"
run 0 watch --once
[[ $(choice jaist) == Egress && ! -f $MOCK_ROOT/started ]]
printf 'ok - flat authentication rejection retreats and pauses safely\n'
if rg -q 'fixture-password|fixture-cookie|fixture-api-value' "$XDG_STATE_HOME" "$MOCK_ROOT/fallback-output"; then exit 1; fi
