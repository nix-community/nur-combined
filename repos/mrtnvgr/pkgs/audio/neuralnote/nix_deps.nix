{ writeText, lib, fetchurl }:
let
  deps = import ./deps.nix { inherit fetchurl; };
  depstrings = lib.lists.forEach deps (dep:
    "${dep.name};${dep.file};${dep.sha1}"
  );
  depfile = lib.strings.concatLines depstrings;
in
writeText "nix-deps.txt" depfile