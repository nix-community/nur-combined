#!/usr/bin/env bash
# Sourced by openconnect-auto.sh. Persistent state contains only timestamps and
# selection ownership and migration metadata; commands come from configuration.
# shellcheck disable=SC2154,SC2034 # Globals are supplied/consumed by the parent script.
fallback_next=0
fallback_managed=false
fallback_deadline=0

fallback_file() {
  local digest
  digest=$(printf '%s' "$1" | sha256sum | cut -c 1-16)
  printf '%s/fallback-%s.json\n' "$state" "$digest"
}
fallback_save() {
  local file=$1 retry=$2 pending=$3 temporary selected=''
  if (($# >= 4)); then
    selected=$4
  elif [[ -f $file ]]; then selected=$(jq -r '.autoSelection // ""' "$file" 2>/dev/null); fi
  temporary=$(mktemp "$state/.fallback.XXXXXX") || return 75
  jq -cn --argjson retry "$retry" --argjson pending "$pending" --arg selected "$selected" \
    '{initialized:true, retryAt:$retry, pendingSince:$pending,autoSelection:$selected}' >"$temporary" || return 75
  mv -f "$temporary" "$file"
}
fallback_select() {
  rpc SelectOutbound "$(jq -cn --arg group "$1" --arg outbound "$2" '{groupTag:$group,outboundTag:$outbound}')" >/dev/null
}
fallback_active() {
  local route=$1 current=$2 selector parent file
  selector=$(printf '%s' "$route" | jq -r .selector)
  parent=$(printf '%s' "$route" | jq -r .parent)
  if [[ $parent != "$selector" ]]; then
    [[ $current == "$selector" ]]
    return
  fi
  # Flat selectors retain the original mesh/Egress automatic range. A VPN
  # chosen by this controller is also managed until the preferred exits recover.
  printf '%s' "$route" | jq -e --arg current "$current" '.preferred + [.fallback] | index($current)' >/dev/null && return 0
  [[ $current == "$endpoint" ]] || return 1
  file=$(fallback_file "$selector")
  [[ -f $file ]] && jq -e --arg endpoint "$endpoint" '.autoSelection == $endpoint' "$file" >/dev/null 2>&1
}
fallback_choose() {
  local route=$1 want=$2 groups parent selector current parent_choice file retry pending
  parent=$(printf '%s' "$route" | jq -r .parent)
  selector=$(printf '%s' "$route" | jq -r .selector)
  groups=$(rpc SubscribeGroups) || return $?
  printf '%s' "$groups" | jq -e '.group | type == "array" and length > 0' >/dev/null 2>&1 || return 75
  # Recheck after probes/authentication so explicit manual selections win.
  parent_choice=$(printf '%s' "$groups" | jq -er --arg parent "$parent" '.group[] | select(.tag == $parent) | .selected') || return 75
  fallback_active "$route" "$parent_choice" || return 0
  current=$(printf '%s' "$groups" | jq -er --arg selector "$selector" '.group[] | select(.tag == $selector) | .selected') || return 65
  if [[ $current != "$want" ]]; then
    fallback_select "$selector" "$want" || return $?
    printf '%s: %s -> %s\n' "$selector" "$current" "$want" >&2
  fi
  file=$(fallback_file "$selector")
  retry=$(jq -r '.retryAt // 0' "$file" 2>/dev/null)
  pending=$(jq -r '.pendingSince // 0' "$file" 2>/dev/null)
  fallback_save "$file" "${retry:-0}" "${pending:-0}" "$want"
}
fallback_probe() {
  local member=$1 probe=$2 control encoded url response
  control=$(printf '%s' "$settings" | jq -r '.clashAPIURL | rtrimstr("/")')
  encoded=$(jq -rn --arg value "$member" '$value | @uri')
  url=$(jq -rn --arg value "$probe" '$value | @uri')
  # curl config accepts quoted strings; JSON quoting also escapes quotes and
  # backslashes in a bearer secret. The header remains on stdin, never argv.
  response=$(printf '%s' "$api_secret" | jq -Rr '"header = " + ("Authorization: Bearer " + . | @json)' |
    curl --config - --noproxy '*' --silent --fail --max-time 5 \
      "$control/proxies/$encoded/delay?url=$url&timeout=3000" 2>/dev/null) || return 1
  printf '%s' "$response" | jq -e '.delay | type == "number" and . >= 0' >/dev/null 2>&1
}
fallback_defer() {
  local route=$1 now=$2 file fallback retry
  file=$(fallback_file "$(printf '%s' "$route" | jq -r .selector)")
  fallback=$(printf '%s' "$route" | jq -r .fallback)
  retry=$(printf '%s' "$settings" | jq -r .fallbackRetrySeconds)
  fallback_deadline=0
  fallback_save "$file" "$((now + retry))" 0 || return $?
  fallback_choose "$route" "$fallback"
}
fallback_tick() {
  local code
  [[ $(printf '%s' "$settings" | jq '.fallbacks | length') != 0 ]] || return 0
  (($(date +%s) >= fallback_next)) || return 0
  acquire_lock || return $?
  fallback_tick_locked
  code=$?
  release_lock
  return "$code"
}
fallback_tick_locked() {
  local now groups route selector parent file initialized current preferred member probe
  local retry pending vpn fallback grace healthy
  [[ $(printf '%s' "$settings" | jq '.fallbacks | length') != 0 ]] || return 0
  now=$(date +%s)
  ((now >= fallback_next)) || return 0
  fallback_next=$((now + $(printf '%s' "$settings" | jq -r .fallbackPollSeconds)))
  load_api_secret || return $?
  groups=$(rpc SubscribeGroups) || return $?
  printf '%s' "$groups" | jq -e '.group | type == "array" and length > 0' >/dev/null 2>&1 || return 75
  fallback_managed=false
  fallback_deadline=0
  while IFS= read -r route; do
    selector=$(printf '%s' "$route" | jq -r .selector)
    parent=$(printf '%s' "$route" | jq -r .parent)
    # A running configuration may not contain these selectors yet. Leave routing
    # untouched until the configuration has been applied.
    printf '%s' "$groups" | jq -e --arg selector "$selector" --arg parent "$parent" \
      'any(.group[]; .tag == $selector) and any(.group[]; .tag == $parent)' >/dev/null || continue
    file=$(fallback_file "$selector")
    initialized=false retry=0 pending=0
    if [[ -f $file ]]; then
      initialized=$(jq -r '.initialized == true' "$file" 2>/dev/null)
      retry=$(jq -r 'if (.retryAt | type) == "number" then .retryAt | floor else 0 end' "$file" 2>/dev/null)
      pending=$(jq -r 'if (.pendingSince | type) == "number" then .pendingSince | floor else 0 end' "$file" 2>/dev/null)
    fi
    current=$(printf '%s' "$groups" | jq -er --arg parent "$parent" '.group[] | select(.tag == $parent) | .selected') || return 65
    if [[ $initialized != true ]]; then
      # Existing primary/fallback choices were managed automatically before the
      # subgroup existed. Migrate them once; preserve explicit VPN/bastion picks.
      if [[ $parent != "$selector" ]]; then
        printf '%s' "$route" | jq -e --arg current "$current" '.preferred + [.fallback] | index($current)' >/dev/null && {
          fallback_select "$parent" "$selector" || return $?
          current=$selector
        }
      fi
      fallback_save "$file" 0 0 || return $?
    fi
    if ! fallback_active "$route" "$current"; then
      fallback_save "$file" "$retry" 0 "" || return $?
      continue
    fi
    fallback_managed=true
    preferred=$(printf '%s' "$route" | jq -c .preferred)
    probe=$(printf '%s' "$route" | jq -r .probeURL)
    fallback=$(printf '%s' "$route" | jq -r .fallback)
    healthy=''
    while IFS= read -r member; do
      if fallback_probe "$member" "$probe"; then
        healthy=$member
        break
      fi
    done < <(printf '%s' "$preferred" | jq -r '.[]')
    if [[ -n $healthy ]]; then
      fallback_choose "$route" "$healthy" || return $?
      fallback_save "$file" 0 0 || return $?
      continue
    fi
    vpn=$(status) || return $?
    if ((retry > now)); then
      fallback_choose "$route" "$fallback" || return $?
    elif [[ $(printf '%s' "$vpn" | jq -r .state) == connected ]]; then
      if fallback_probe "$endpoint" "$probe"; then
        fallback_choose "$route" "$endpoint" || return $?
        fallback_save "$file" 0 0 || return $?
      else fallback_defer "$route" "$now" || return $?; fi
    elif [[ -f $pause_file ]]; then
      fallback_choose "$route" "$fallback" || return $?
    else
      grace=$(printf '%s' "$settings" | jq -r .fallbackAuthSeconds)
      if ((pending > 0 && now - pending >= grace)); then
        fallback_defer "$route" "$now" || return $?
      else
        ((pending > 0)) || pending=$now
        fallback_save "$file" 0 "$pending" || return $?
        fallback_deadline=$((pending + grace))
        fallback_choose "$route" "$endpoint" || return $?
      fi
    fi
  done < <(printf '%s' "$settings" | jq -c '.fallbacks[]')
}
fallback_resume() {
  local selector file
  while IFS= read -r selector; do
    file=$(fallback_file "$selector")
    [[ ! -f $file ]] || fallback_save "$file" 0 0 || return $?
  done < <(printf '%s' "$settings" | jq -r '.fallbacks[].selector')
}
fallback_auth_result() {
  local code=$1 groups route selector parent current now
  case $code in 0 | 73 | 130) return 0 ;; esac
  [[ $(printf '%s' "$settings" | jq '.fallbacks | length') != 0 ]] || return 0
  groups=$(rpc SubscribeGroups) || return $?
  now=$(date +%s)
  while IFS= read -r route; do
    selector=$(printf '%s' "$route" | jq -r .selector)
    parent=$(printf '%s' "$route" | jq -r .parent)
    current=$(printf '%s' "$groups" | jq -r --arg selector "$selector" '.group[] | select(.tag == $selector) | .selected')
    [[ $current == "$endpoint" ]] || continue
    current=$(printf '%s' "$groups" | jq -r --arg parent "$parent" '.group[] | select(.tag == $parent) | .selected')
    fallback_active "$route" "$current" || continue
    fallback_defer "$route" "$now" || return $?
  done < <(printf '%s' "$settings" | jq -c '.fallbacks[]')
  fallback_next=0
}
