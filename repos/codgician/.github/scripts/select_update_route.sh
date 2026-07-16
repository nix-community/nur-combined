#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

updater_exit=${1:?updater exit is required}
package_changes=${2:?package changes state is required}
version_state=${3-}
deterministic_exit=${4-}

if [[ ! "$updater_exit" =~ ^[0-9]+$ ]]; then
  echo "Invalid updater exit: $updater_exit" >&2
  exit 2
fi
if [[ "$package_changes" != "true" && "$package_changes" != "false" ]]; then
  echo "Invalid package changes state: $package_changes" >&2
  exit 2
fi

if [[ "$updater_exit" != "0" ]]; then
  printf 'ai'
elif [[ "$package_changes" == "false" || "$version_state" == "unchanged" ]]; then
  printf 'up-to-date'
elif [[ "$version_state" == "advanced" && "$deterministic_exit" == "0" ]]; then
  printf 'deterministic'
else
  printf 'ai'
fi
