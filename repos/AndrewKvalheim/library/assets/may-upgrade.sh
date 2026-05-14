#!/usr/bin/env bash
set -Eeuo pipefail

results=()

is_home() {
  if nc -z -w 5 'nix-store.home.arpa' 22 &>/dev/null; then
    results+=('☑ Home'); return 0
  else
    results+=('☐ Home'); return 1
  fi
}

is_closed() {
  if [[ "$(< '/proc/acpi/button/lid/LID/state')" == *closed* ]]; then
    results+=('☑ Closed'); return 0
  else
    results+=('☐ Closed'); return 1
  fi
}

if is_closed && is_home; then
  echo 'Allowing update:' "${results[@]}" >&2; exit 0
else
  echo 'Disallowing update:' "${results[@]}" >&2; exit 1
fi
