#!/usr/bin/env bash
set -Eeuo pipefail

description_path="$1"

debug() { [[ -z "${DEBUG:-}" ]] || echo "$1" >&2; }

# Scan description file and collect suggestions
injection_position=''; position='1'; removed_version=''; scope=''; declare -A suggestions=()
while read -r line; do
  debug "[2m┃ $line[22m"
  sign=''; version=''

  if [[ "$line" == 'JJ:'* ]]; then
    if [[ "$line" =~ ^JJ:\ {5}\+{3}\ .*\/([^\/.]+).*$ ]]; then
      scope="${BASH_REMATCH[1]}"
      debug "scope = “$scope”"
      suggestions["$scope"]=''
      debug "suggestions[$scope] = “${suggestions["$scope"]}”"
    fi

    if [[ "$line" =~ ^JJ:\ {5}([-+]) ]]; then
      sign="${BASH_REMATCH[1]}"

      if [[ "$line" =~ [^[:alnum:]]([[:digit:]]+(\.[[:digit:]]+)*(-unstable[-[:digit:]]*)?)[^[:alnum:]] ]]; then
        version="${BASH_REMATCH[1]}"
        debug "version = $sign “$version”"
      fi

      if [[ "$sign" == '-' ]]; then
        removed_version="$version"
      else
        if [[ -n "$removed_version" && -n "$version" ]]; then
          suggestions["$scope"]="$removed_version → $version"
          debug "suggestions[$scope] = “${suggestions["$scope"]}”"
        fi

        removed_version=''
      fi
    fi
  else
    if [[ -z "$injection_position" ]]; then
      injection_position="$position"
      debug "injection_position = line $injection_position"
    fi
  fi

  (( position += 1 ))
done < "$description_path"

# Inject suggestions into description file
if (( ${#suggestions[@]} > 0 )); then
  message="$(
    for scope in "${!suggestions[@]}"; do
      echo "JJ: $scope: ${suggestions[$scope]}"
    done \
    | sort --version-sort
  )"

  awk \
    --assign injection_position="${injection_position:-1}" \
    --assign message="$message" \
    --include 'inplace' \
    'NR == injection_position { print message; } { print $0; }' \
    "$description_path"
fi

exec $EDITOR "$description_path"
