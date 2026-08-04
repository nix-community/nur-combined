#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
baseline_main_program=${2:?baseline main program is required}
old_version=${3:?old version is required}
new_version_file=${4:?new version output file is required}

bash .github/scripts/validate_candidate_structure.sh \
  "$package" \
  "$old_version" \
  "$new_version_file"

.github/scripts/validate_bump.sh "$package" "$baseline_main_program"
