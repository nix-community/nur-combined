#!/usr/bin/env bash

source shellvaculib.bash || exit 1

svl_no_args $#

if [[ $HOSTNAME != "prophecy" ]]; then
  svl_die "only makes sense to run this on prophecy"
fi

declare -a cmd=(
  rsync
  --verbose
  --partial
  --progress
  --recursive
  --times
  --xattrs
  --timeout=180
  --sparse
  --filter='protect *' #no deletion should happen on dest
  --filter='hide /unfinished'

  #defaults that im making explicit
  --no-links
  --no-perms
  --no-group
  --no-owner
  --no-devices
  --no-specials
  --no-acls
  --no-atimes
  --no-crtimes
  --no-hard-links

  solis:/xstore/torrents/
  /propdata/media/disorganized/solis-torrents/
  --partial-dir=.rsync-partial
)

svl_verbose_run exec "${cmd[@]}"
