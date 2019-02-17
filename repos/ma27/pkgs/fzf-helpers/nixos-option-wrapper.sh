#! /usr/bin/env bash

script='
with import <nixpkgs/lib>;
let
  options = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = []; }).options;
in
  map (x: x.name)
    (filter
      (opt: opt.visible && !opt.internal)
      (optionAttrSetToDocList options))
'

opt=$(nix-instantiate --strict --eval -E "$script" | xargs echo | tr " " "\n" | sed '$ d' | sed 1d | fzf)

if [ ! -z "$opt" ]; then
  echo >&2 -e "$(tput bold)$ nixos-option $opt$(tput sgr0)"
  nixos-option $opt
fi
