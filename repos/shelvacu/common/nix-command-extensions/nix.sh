#!/bin/bash

# replaceme START
declare -A cache_to_url
cache_to_url["foo"]="https://example.com/some-nix-cache"

declare -a caches_to_use=("foo")

declare nixCmd="foo"
# replaceme END

declare -a preArgs
declare -a passThruArgs
cache_name=""
function valid_cache_name() {
  cache_name="$1"
  if [[ $cache_name == -* ]]; then
    echo "invalid cache name" >&2
    exit 1
  fi
}
while [[ -n $1 ]]; do
  arg="$1"
  shift
  case "$arg" in
  "--without-cache")
    cache_name="$1"
    shift
    valid_cache_name "$cache_name"
    caches_to_use=("${caches_to_use[@]/$cache_name/}")
    ;;
  "--with-cache")
    cache_name="$1"
    shift
    valid_cache_name "$cache_name"
    caches_to_use+=("$cache_name")
    ;;
  "--only-cache")
    cache_name="$1"
    shift
    valid_cache_name "$cache_name"
    caches_to_use=("$cache_name")
    ;;
  "--on-prop")
    if [[ $HOSTNAME == "prophecy" ]]; then
      echo "Warn: skipping --on-prop: already on prop" >&2
    else
      passThruArgs+=("--builders" "ssh://prop x86_64-linux,aarch64-linux" "--max-jobs" "0" "--option" "builders-use-substitutes" "true")
    fi
    ;;
  "--")
    passThruArgs+=("$arg" "$@")
    break
    ;;
  *)
    passThruArgs+=("$arg")
    ;;
  esac
done

declare -a substituters
for c in "${caches_to_use[@]}"; do
  url="${cache_to_url["$c"]}"
  substituters+=("$url")
done

substituters_together="${substituters[*]}"

preArgs+=("--option" "substituters" "$substituters_together")

exec "$nixCmd" "${preArgs[@]}" "${passThruArgs[@]}"
