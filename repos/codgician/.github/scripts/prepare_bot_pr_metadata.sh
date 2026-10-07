#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
old_version=${2-}
new_package=${3:?new package state is required}
output_dir=${4:?output directory is required}
attempt=${5:?repair attempt is required}
repair_kind=${6:-}
failed_run_url=${7:-}
if [[ -z "$repair_kind" ]]; then
  if [[ "$new_package" == "true" ]]; then
    repair_kind=new-package
  else
    repair_kind=update
  fi
fi

if [[ ! "$package" =~ ^[a-z][a-z0-9_-]{0,63}$ ]]; then
  echo "Invalid package attribute: $package" >&2
  exit 2
fi
if [[ "$new_package" != "true" && "$new_package" != "false" ]]; then
  echo "Invalid new package state: $new_package" >&2
  exit 2
fi
if [[ ! "$attempt" =~ ^[1-9][0-9]*$ ]]; then
  echo "Invalid repair attempt: $attempt" >&2
  exit 2
fi
if [[ "$repair_kind" != "update" && "$repair_kind" != "new-package" && "$repair_kind" != "build-fix" ]]; then
  echo "Invalid repair kind: $repair_kind" >&2
  exit 2
fi
if [[ ( "$new_package" == "true" && "$repair_kind" != "new-package" ) || ( "$new_package" == "false" && "$repair_kind" == "new-package" ) ]]; then
  echo "Repair kind does not match new package state: $repair_kind" >&2
  exit 2
fi
if [[ "$repair_kind" == "build-fix" && -z "$failed_run_url" ]]; then
  echo "Build repair requires a failed run URL" >&2
  exit 2
fi
if [[ -n "$failed_run_url" && ( "$failed_run_url" == *$'\n'* || ! "$failed_run_url" =~ ^https?://[^[:space:]]{1,2048}$ ) ]]; then
  echo "Invalid failed run URL" >&2
  exit 2
fi

new_version=$(nix eval --raw ".#$package.version")
if [[ ! "$new_version" =~ ^[0-9A-Za-z][0-9A-Za-z._+~-]{0,127}$ ]]; then
  echo "Invalid repaired package version: $new_version" >&2
  exit 1
fi
if [[ "$new_package" == "false" && ! "$old_version" =~ ^[0-9A-Za-z][0-9A-Za-z._+~-]{0,127}$ ]]; then
  echo "Invalid base package version: $old_version" >&2
  exit 1
fi
if ! changelog=$(nix eval --raw ".#$package.meta.changelog" 2>/dev/null); then
  changelog=
fi
if [[ -n "$changelog" && ( "$changelog" == *$'\n'* || ! "$changelog" =~ ^https?://[^[:space:]]{1,2048}$ ) ]]; then
  echo "Invalid changelog URL" >&2
  exit 1
fi

mkdir -p "$output_dir"
if [[ "$new_package" == "true" ]]; then
  homepage=$(nix eval --raw ".#$package.meta.homepage")
  if [[ "$homepage" == *$'\n'* || ! "$homepage" =~ ^https?://[^[:space:]]{1,2048}$ ]]; then
    echo "Invalid package homepage" >&2
    exit 1
  fi
  printf '%s: init at %s' "$package" "$new_version" > "$output_dir/title"
  {
    printf "Add \`%s\` at \`%s\` from %s.\n\n" "$package" "$new_version" "$homepage"
    printf -- "- Origin: \`AI repair\`\n"
    printf -- '- Validation: full required pull-request CI before review\n'
    if [[ -n "$changelog" ]]; then
      printf -- '- Changelog: %s\n' "$changelog"
    fi
  } > "$output_dir/body.md"
else
  if [[ "$repair_kind" == "build-fix" ]]; then
    printf '%s: fix build' "$package" > "$output_dir/title"
  else
    printf '%s: %s -> %s' "$package" "$old_version" "$new_version" > "$output_dir/title"
  fi
  {
    if [[ "$repair_kind" == "build-fix" ]]; then
      printf "Automated build repair of \`%s\` at \`%s\`.\n\n" "$package" "$new_version"
    else
      printf "Automated update of \`%s\` from \`%s\` to \`%s\`.\n\n" "$package" "$old_version" "$new_version"
    fi
    printf -- "- Origin: \`AI repair\`\n"
    printf -- '- Validation: full required pull-request CI before review\n'
    if [[ -n "$failed_run_url" ]]; then
      printf -- '- Failed run: %s\n' "$failed_run_url"
    fi
    if [[ -n "$changelog" ]]; then
      printf -- '- Changelog: %s\n' "$changelog"
    fi
  } > "$output_dir/body.md"
fi
printf 'bot repair(%s): CI attempt %s' "$package" "$attempt" > "$output_dir/commit-message"
