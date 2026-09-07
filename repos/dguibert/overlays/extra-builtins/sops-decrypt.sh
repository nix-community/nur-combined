#!/usr/bin/env bash
#set -x
encFile="$1"
key="${2:-data}"

(
  umask 077
  if test -e "$encFile"; then
    case "$key" in
      data)
        @sops@/bin/sops --extract "[\"$key\"]" -d "$encFile"
        ;;
      *)
        echo "\"$(@sops@/bin/sops --extract "[\"$key\"]" -d "$encFile")\""
        ;;
    esac
  else
    echo "{ success=false; }"
  fi
)
