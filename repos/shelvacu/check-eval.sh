#!/usr/bin/env bash
source shellvaculib.bash

svl_exact_args $# 0
svl_assert_probably_in_script_dir

declare -a nix_eval=(
  nix eval
  --show-trace
)

declare -a hosts=(
  triple-dezert
  compute-deck
  liam
  lp0
  #skip shel-installer-*
  fw
  legtop
  mmm
  prophecy
)

set -x

"${nix_eval[@]}" --impure ".#.nixOnDroidConfigurations.default.activationPackage"

for host in "${hosts[@]}"; do
  "${nix_eval[@]}" ".#.nixosConfigurations.${host}.config.system.build.toplevel"
done
