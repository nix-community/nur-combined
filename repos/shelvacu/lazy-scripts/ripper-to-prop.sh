#!/usr/bin/env bash

source shellvaculib.bash || exit 1

svl_exact_args $# 0

if [[ $HOSTNAME != "prophecy" ]]; then
  svl_die "only makes sense to run this on prophecy"
fi

set -x
ssh ripper sudo chmod g+w -R /finished-rips
rsync --remove-source-files -rvP ripper:/finished-rips/ /propdata/archive/discs/
