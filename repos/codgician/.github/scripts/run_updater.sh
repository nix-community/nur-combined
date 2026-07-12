#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
if [[ ! "$package" =~ ^[a-z][a-z0-9_-]{0,63}$ ]]; then
  echo "Invalid package attribute: $package" >&2
  exit 2
fi

exec nix-shell tasks/update.nix \
  --argstr package "$package" \
  --argstr commit false \
  --argstr skip-prompt true
