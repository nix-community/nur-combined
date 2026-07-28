#!/usr/bin/env bash

source shellvaculib.bash || exit 1

svl_auto_sudo

declare make_snapshot=false

for arg; do
  case "$arg" in
  --make-snapshot)
    make_snapshot=true
    ;;
  *)
    svl_die "unrecognized arg $arg"
    ;;
  esac
done

declare -a syncoid_run

if command -v syncoid >/dev/null; then
  syncoid_run=(syncoid)
else
  syncoid_run=(nix shell 'nixpkgs#sanoid' --command syncoid)
fi

if ! command -v zfs >/dev/null; then
  svl_die "cannot find zfs command"
fi

if [[ ${HOSTNAME:-} != "fw" ]]; then
  svl_die "this script only works on fw"
fi

if [[ $make_snapshot == true ]]; then
  declare datestr
  datestr="$(date -I)"
  declare snap_name="semiauto--fw--$datestr"
  svl_verbose_run zfs snapshot -o vacu:made_by="<vacu>/scripts/fw-syncoid-to-prop.sh" fw/root@"$snap_name"
fi

declare -a syncoid_cmd=(
  "${syncoid_run[@]}"
  --no-sync-snap
  --use-hold
  fw/root
  prop:propdata/trip/fw-backup-2/root
)

svl_verbose_run "${syncoid_cmd[@]}"
