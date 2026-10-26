#!/usr/bin/env bash
# Credentials and RPC bodies travel only through pipes or inherited descriptors.
set +e
set -uo pipefail
umask 077
libdir="@lib@"
[[ $libdir != @* ]] || libdir="${BASH_SOURCE[0]%/*}"
config="${XDG_CONFIG_HOME:-$HOME/.config}/sing-box/openconnect-auto.json"
action=login method='' once=false
active_pid='' error_file='' auth_session='' lock_owned=false

usage() {
  printf '%s\n' 'Usage: sing-box-openconnect-auth [--config FILE] [watch [--once]|login [--method NAME]|status|cancel]'
}
fail() { printf 'openconnect-auto: %s\n' "$1" >&2; }
while (($#)); do
  case $1 in
    --help | -h)
      usage
      exit 0
      ;;
    --config | --method)
      (($# >= 2)) || {
        usage >&2
        exit 64
      }
      if [[ $1 == --config ]]; then config=$2; else method=$2; fi
      shift 2
      ;;
    watch | login | status | cancel)
      action=$1
      shift
      ;;
    --once)
      once=true
      shift
      ;;
    *)
      usage >&2
      exit 64
      ;;
  esac
done
[[ $action == login || -z $method ]] || {
  usage >&2
  exit 64
}
[[ $action == watch || $once == false ]] || {
  usage >&2
  exit 64
}

if ! settings=$(jq -ce '
  def command: type == "array" and length > 0 and all(.[]; type == "string" and length > 0 and (contains("\u0000") | not));
  .defaultMethod //= "certificate" | .pollSeconds //= 5 | .fallbacks //= []
  | .fallbackPollSeconds //= 30 | .fallbackRetrySeconds //= 300 | .fallbackAuthSeconds //= 240
  | .fallbacks |= map(.parent //= .selector)
  | select((.endpoint | type) == "string" and (.endpoint | length) > 0)
  | select(.apiURL | test("^http://(127\\.0\\.0\\.1|localhost|\\[::1\\]):[0-9]+/?$"))
  | select(.gateway | test("^https://[A-Za-z0-9.-]+(:[0-9]+)?/?$"))
  | select((.selectors | type) == "array" and all(.selectors[]; type == "string"))
  | select(.apiSecretCommand | command)
  | select((.authCommands | type) == "object" and (.authCommands | length) > 0 and all(.authCommands[]; command))
  | select(.authCommands[.defaultMethod] != null)
  | select((.fallbacks | type) == "array" and all(.fallbacks[];
      ([.selector, .parent, .fallback, .probeURL] | all(.[]; type == "string" and length > 0 and (test("[\r\n\u0000]") | not)))
      and (.preferred | type) == "array" and (.preferred | length) > 0
      and all(.preferred[]; type == "string" and length > 0)))
  | select((.fallbacks | length) == 0 or (.clashAPIURL | test("^http://(127\\.0\\.0\\.1|localhost|\\[::1\\]):[0-9]+/?$")))
  | select([.fallbackPollSeconds, .fallbackRetrySeconds, .fallbackAuthSeconds] | all(.[]; type == "number" and . >= 1 and . <= 86400 and . == floor))
  | select((.pollSeconds | type) == "number" and .pollSeconds >= 1 and .pollSeconds <= 60 and .pollSeconds == (.pollSeconds | floor))
  | select((.credentials | type) == "array" and all(.credentials[];
      (.path | type) == "array" and (.path | length) > 0 and all(.path[]; type == "string" and length > 0)
      and (.command | command) and ((.encoding // "text") as $encoding | ["text", "gopass-base64"] | index($encoding)) != null
      and (.methods == null or ((.methods | type) == "array" and all(.methods[]; type == "string")))))
' "$config" 2>/dev/null); then
  fail 'invalid configuration'
  exit 65
fi
endpoint=$(printf '%s' "$settings" | jq -r .endpoint)
api_url=$(printf '%s' "$settings" | jq -r '.apiURL | rtrimstr("/")')
gateway=$(printf '%s' "$settings" | jq -r .gateway)
poll=$(printf '%s' "$settings" | jq -r .pollSeconds)
method=${method:-$(printf '%s' "$settings" | jq -r .defaultMethod)}
printf '%s' "$settings" | jq -e --arg method "$method" '.authCommands[$method] != null' >/dev/null || {
  fail 'unsupported authentication method'
  exit 64
}
key=$(printf '%s\n%s' "$api_url" "$endpoint" | sha256sum | cut -c 1-16)
state="${XDG_STATE_HOME:-$HOME/.local/state}/openconnect-auto/$key"
mkdir -p "$state" || exit 65
chmod 700 "$state" || exit 65
pause_file="$state/paused"
lock_dir="$state/auth.lock"
api_secret=
login_started=false fallback_managed=false fallback_deadline=0

stop_child() {
  if [[ -n $active_pid ]]; then
    kill -TERM "$active_pid" 2>/dev/null || true
    wait "$active_pid" 2>/dev/null || true
    active_pid=
  fi
}
release_lock() {
  if [[ $lock_owned == true ]]; then
    rm -f "$lock_dir/pid"
    rmdir "$lock_dir" 2>/dev/null || true
    lock_owned=false
  fi
}
cleanup() {
  stop_child
  [[ -z $error_file ]] || rm -f "$error_file"
  release_lock
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

pause() { printf '%s\n' "$1" >"$pause_file"; }
acquire_lock() {
  local owner
  if ! mkdir "$lock_dir" 2>/dev/null; then
    owner=$(cat "$lock_dir/pid" 2>/dev/null)
    if [[ $owner =~ ^[1-9][0-9]*$ ]] && ! kill -0 "$owner" 2>/dev/null; then
      # Only one contender reaps a dead owner's directory. Others return busy.
      mkdir "$lock_dir/reaping" 2>/dev/null || return 73
      if [[ $(cat "$lock_dir/pid" 2>/dev/null) == "$owner" ]]; then
        rm -f "$lock_dir/pid"
        rmdir "$lock_dir/reaping" "$lock_dir" 2>/dev/null || return 73
      else
        rmdir "$lock_dir/reaping" 2>/dev/null || true
        return 73
      fi
      mkdir "$lock_dir" 2>/dev/null || return 73
    else return 73; fi
  fi
  lock_owned=true
  printf '%s\n' "$$" >"$lock_dir/pid" || return 65
}

# Configuration contains argument arrays, never shell fragments or secret values.
run_command() {
  local spec=$1
  local -a argv=()
  mapfile -d '' -t argv < <(printf '%s' "$spec" | jq -j '.[] | ., "\u0000"')
  ((${#argv[@]})) || return 65
  timeout --foreground --kill-after=3s 30s "${argv[@]}" </dev/null
}
load_api_secret() {
  [[ -z $api_secret ]] || return 0
  api_secret=$(run_command "$(printf '%s' "$settings" | jq -c .apiSecretCommand)" 2>/dev/null) || return 65
  [[ -n $api_secret && $api_secret != *$'\n'* && $api_secret != *$'\r'* ]] || return 65
}
rpc() {
  local name=$1 body=${2:-'{}'} response code duration=8s
  load_api_secret || return 65
  [[ $name != Subscribe* ]] || duration=1s
  response=$({
    printf 'Authorization: Bearer %s\n\n' "$api_secret"
    printf '%s\n' "$body"
  } | buf curl --protocol grpc --http2-prior-knowledge --header @- --data @- \
    --reflect-header '*' --timeout "$duration" "$api_url/daemon.StartedService/$name" 2>/dev/null)
  code=$?
  if ((code == 0)) || [[ $name == Subscribe* && $code == 32 && -n $response ]]; then
    printf '%s' "$response" | jq -ces 'last' 2>/dev/null || return 75
  else
    case $code in 24 | 40 | 56 | 96 | 128) return 65 ;; *) return 75 ;; esac
  fi
}
status() {
  local update
  update=$(rpc SubscribeOpenConnectStatus) || return $?
  printf '%s' "$update" | jq -ce --arg endpoint "$endpoint" '.endpoints[]? | select(.endpointTag == $endpoint)' 2>/dev/null || return 75
}
using_vpn() {
  local groups
  groups=$(rpc SubscribeGroups) || return $?
  printf '%s' "$groups" | jq -e '.group | type == "array" and length > 0' >/dev/null 2>&1 || return 75
  printf '%s' "$groups" | jq -e -L "$libdir" --argjson roots "$(printf '%s' "$settings" | jq -c .selectors)" \
    --arg target "$endpoint" 'include "auth"; .group | selected($roots; $target)' >/dev/null 2>&1
}
credentials() {
  local result='{}' item raw value path encoding
  while IFS= read -r item; do
    raw=$(run_command "$(printf '%s' "$item" | jq -c .command)" 2>/dev/null) || return 65
    encoding=$(printf '%s' "$item" | jq -r '.encoding // "text"')
    value=$(printf '%s' "$raw" | jq -Rsc -L "$libdir" --arg encoding "$encoding" 'include "auth"; credential($encoding)' 2>/dev/null) || return 65
    path=$(printf '%s' "$item" | jq -c .path)
    result=$(printf '%s\n%s\n' "$result" "$value" | jq -cs --argjson path "$path" '.[1] as $value | .[0] | setpath($path; $value)') || return 65
  done < <(printf '%s' "$settings" | jq -c --arg method "$method" '.credentials[] | select(.methods == null or (.methods | index($method)) != null)')
  printf '%s\n' "$result"
}
sanitize_error() {
  jq -Rrs 'try capture("(?m)^(?<code>input-required|cancelled|timeout|network|rejected|unsupported|unsafe-destination|invalid-input):").code catch "authentication"' >"$1"
}
authenticate() {
  local input spec fd line result='' code reason check elapsed=0
  local -a argv=()
  input=$(credentials) || return 65
  spec=$(printf '%s' "$settings" | jq -c --arg method "$method" '.authCommands[$method]')
  mapfile -d '' -t argv < <(printf '%s' "$spec" | jq -j '.[] | ., "\u0000"')
  error_file=$(mktemp "$state/failure.XXXXXX") || return 65
  if [[ $action == login && -t 0 && -t 2 ]]; then
    exec {fd}< <(exec timeout --foreground --kill-after=3s 210s "${argv[@]}" 3< <(printf '%s\n' "$input") </dev/tty 2> >(tee /dev/tty | sanitize_error "$error_file"))
  else
    exec {fd}< <(exec timeout --kill-after=3s 210s "${argv[@]}" 3< <(printf '%s\n' "$input") </dev/null 2> >(sanitize_error "$error_file"))
  fi
  active_pid=$!
  input=
  while :; do
    if IFS= read -r -t 1 -u "$fd" line; then
      result+="$line"$'\n'
      if ((${#result} > 2097152)); then
        stop_child
        exec {fd}<&-
        rm -f "$error_file"
        return 65
      fi
    else
      code=$?
      ((code > 128)) || break
      if [[ -f $pause_file ]]; then
        stop_child
        exec {fd}<&-
        rm -f "$error_file"
        return 130
      fi
      if [[ $action == watch ]] && ((fallback_deadline > 0 && $(date +%s) >= fallback_deadline)); then
        stop_child
        exec {fd}<&-
        rm -f "$error_file"
        return 75
      fi
      if [[ $action == watch ]]; then
        using_vpn
        check=$?
        if ((check != 0)); then
          stop_child
          exec {fd}<&-
          rm -f "$error_file"
          ((check == 1)) && return 130
          return "$check"
        fi
      fi
      elapsed=$((elapsed + 1))
      ((elapsed < 210)) || {
        stop_child
        break
      }
    fi
  done
  exec {fd}<&-
  wait "$active_pid"
  code=$?
  active_pid=
  reason=$(cat "$error_file" 2>/dev/null)
  rm -f "$error_file"
  if ((code != 0)); then
    case $code:$reason in 124:* | *:network | *:timeout) return 75 ;; 130:* | *:cancelled) return 130 ;; *) return 65 ;; esac
  fi
  auth_session=$(printf '%s' "$result" | jq -cse 'select(length == 1) | .[0] | select(type == "object" and (.cookies | type) == "object")' 2>/dev/null) || return 65
}
login() {
  local current challenge response session check attempt
  login_started=false
  acquire_lock || return $?
  if [[ $action == login ]]; then
    rm -f "$pause_file"
    fallback_resume || return $?
  elif [[ -f $pause_file ]]; then
    release_lock
    return 0
  fi
  current=$(status) || return $?
  if [[ $(printf '%s' "$current" | jq -r .state) == connected ]]; then
    [[ $action != login ]] || printf '%s: already connected\n' "$endpoint"
    release_lock
    return 0
  fi
  challenge=$(printf '%s' "$current" | jq -ce '.authChallenge | select((.id | type) == "string" and .browser != null)') || return 75
  printf '%s' "$challenge" | jq -e -L "$libdir" --arg gateway "$gateway" 'include "auth";
    (.browser.url | origin) == ($gateway | origin)
    and (.browser.cookieNames | length) > 0 and (.browser.headerNames // [] | length) == 0' >/dev/null 2>&1 || return 65
  printf '%s: authenticating\n' "$endpoint" >&2
  login_started=true
  authenticate
  check=$?
  ((check == 0)) || return "$check"
  session=$auth_session
  auth_session=
  [[ ! -f $pause_file ]] || return 130
  if [[ $action == watch ]]; then
    using_vpn
    check=$?
    ((check == 0)) || {
      ((check == 1)) && return 130
      return "$check"
    }
  fi
  current=$(status) || return $?
  [[ $(printf '%s' "$current" | jq -r '.authChallenge.id // ""') == "$(printf '%s' "$challenge" | jq -r .id)" ]] || return 75
  response=$(printf '%s\n%s\n' "$session" "$challenge" | jq -cse -L "$libdir" --arg endpoint "$endpoint" --arg gateway "$gateway" 'include "auth"; .[1] as $challenge | .[0] | submission($endpoint; $challenge; $gateway)' 2>/dev/null) || return 65
  rpc SubmitOpenConnectAuthResponse "$response" >/dev/null || return $?
  session='' response=''
  for ((attempt = 0; attempt < 15; attempt++)); do
    [[ ! -f $pause_file ]] || return 130
    current=$(status) || return $?
    case $(printf '%s' "$current" | jq -r .state) in
      connected)
        printf '%s: connected\n' "$endpoint"
        release_lock
        return 0
        ;;
      error) return 65 ;;
    esac
    check=$(printf '%s' "$current" | jq -r '.authChallenge.id // ""')
    [[ -z $check || $check == "$(printf '%s' "$challenge" | jq -r .id)" ]] || return 65
    sleep 1
  done
  return 75
}

# Optional priority selection shares this process with authentication, so there
# is one writer for automatic selectors on both launchd and systemd hosts.
# shellcheck source=tools/openconnect-auth/fallback.sh
# shellcheck disable=SC1091 # Installed library path; linted and tested separately.
source "$libdir/fallback.sh"

case $action in
  status)
    load_api_secret || {
      fail 'API secret unavailable'
      exit 65
    }
    current=$(status) || {
      fail 'local API unavailable or configuration invalid'
      exit 1
    }
    ready=ready
    [[ ! -f $pause_file ]] || ready=paused
    printf '%s: %s; automatic login %s\n' "$endpoint" "$(printf '%s' "$current" | jq -r .state)" "$ready"
    ;;
  cancel)
    pause manual || exit 1
    load_api_secret || {
      fail 'automatic login paused; API secret unavailable'
      exit 65
    }
    current=$(status) || {
      fail 'automatic login paused; local API unavailable'
      exit 1
    }
    body=$(printf '%s' "$current" | jq -ce 'select(.authChallenge != null) | {endpointTag, challengeID: .authChallenge.id}')
    if [[ -n $body ]]; then rpc CancelOpenConnectAuthChallenge "$body" >/dev/null || exit 1; fi
    printf '%s: automatic login paused\n' "$endpoint"
    ;;
  login | watch)
    delay=$poll previous=
    while :; do
      code=0
      if [[ $action == watch ]]; then
        fallback_tick
        code=$?
      fi
      if ((code != 0)); then
        message='waiting for fallback API'
        delay=60
        if ((code == 73)); then
          message='waiting for another login'
          delay=$poll
        fi
        [[ $message == "$previous" ]] || fail "$message"
        previous=$message
        [[ $once != true ]] || exit "$code"
        sleep "$delay" &
        active_pid=$!
        wait "$active_pid"
        active_pid=
        continue
      fi
      if [[ $action == watch && -f $pause_file ]]; then
        message='automatic login paused; run openconnect-login to resume'
      else
        load_api_secret
        selected=$?
        if ((selected == 0)) && [[ $action == watch ]]; then
          using_vpn
          selected=$?
        fi
        if ((selected == 0)); then
          login
          code=$?
          release_lock
          if [[ $action == watch && $login_started == true ]]; then fallback_auth_result "$code" || true; fi
        elif ((selected != 1)); then code=$selected; fi
        case $code in
          0 | 73 | 130)
            message=
            delay=$poll
            ;;
          75)
            message='waiting for local API or network'
            delay=$((delay * 2))
            ((delay >= 60)) || delay=60
            ((delay <= 900)) || delay=900
            [[ $fallback_managed != true ]] || delay=$poll
            ;;
          *)
            pause authentication
            message='automatic login paused; check credentials/configuration, then run openconnect-login'
            delay=$poll
            ;;
        esac
      fi
      [[ -z $message || $message == "$previous" ]] || fail "$message"
      previous=$message
      if [[ $action == login || $once == true ]]; then
        ((code == 0)) && exit 0
        exit "$code"
      fi
      sleep "$delay" &
      active_pid=$!
      wait "$active_pid"
      active_pid=
    done
    ;;
esac
