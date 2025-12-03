#!/usr/bin/env bash
source shellvaculib.bash

svl_exact_args $# 0

svl_auto_sudo

declare top_dataset="trip" snapshot_name snapshot_prefix
declare -a previous_snapshots
declare snapshot_lines
snapshot_lines="$(zfs list -t snapshot --json "$top_dataset" | jq -r '.datasets|values[]|.snapshot_name')"
mapfile -t previous_snapshots <<<"$snapshot_lines"

snapshot_prefix="semiauto--$(date '+%Y-%m-%d')--"
declare -i idx=1
while true; do
  snapshot_name="${snapshot_prefix}${idx}"
  # the only purpose of svl_in_array is to be used in a condition
  # shellcheck disable=SC2310
  if ! svl_in_array "$snapshot_name" "${previous_snapshots[@]}"; then
    break
  fi
  ((idx++)) || true
done

declare -a all_datasets
declare all_datasets_lines
all_datasets_lines="$(zfs list -r --json "$top_dataset" | jq -r '.datasets|keys[]')"
mapfile -t all_datasets <<<"$all_datasets_lines"
declare -a should_snap_datasets excluded
for dataset in "${all_datasets[@]}"; do
  case "$dataset" in
  trip/fw-backup | trip/fw-backup/* | trip/fw-backup-2 | trip/fw-backup-2/*)
    excluded+=("$dataset")
    ;;
  *)
    should_snap_datasets+=("$dataset")
    ;;
  esac
done

echo "About to create snapshot ${top_dataset}@${snapshot_name} recursively except for:"
for dataset in "${excluded[@]}"; do
  echo "  - $dataset"
done
echo
echo
read -r -p "Type y to continue: " confirmation
if [[ $confirmation != [yY] ]]; then
  echo "abort"
  exit 1
fi

for dataset in "${should_snap_datasets[@]}"; do
  zfs snapshot "${dataset}@${snapshot_name}"
done
