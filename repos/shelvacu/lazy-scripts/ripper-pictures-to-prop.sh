#!/usr/bin/env bash

source shellvaculib.bash || exit 1

svl_exact_args $# 0

if [[ $HOSTNAME != "prophecy" ]]; then
  svl_die "only makes sense to run this on prophecy"
fi

if [[ $USER != "shelvacu" ]]; then
  svl_die "only makes sens to run this as user shelvacu"
fi

set -x
ssh ripper -- sudo gomtree validate -c -p /pictures -K 'uname,gname,xattr,flags' >"/propdata/archive/t-pictures/$(date -u '+%F_%H-%M-%SZ').mtree"
ssh ripper -- sudo chmod g+w -R /pictures
declare -a cmd=(
  rsync
  --remove-source-files
  --recursive
  --verbose
  --partial
  --progress
  --checksum
  ripper:/pictures/
  /propdata/archive/t-pictures/
)
"${cmd[@]}"
find /propdata/archive/t-pictures -user shelvacu -type f -exec chmod a-w '{}' \;
