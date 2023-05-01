{ lib }:

rimePackages:

let
  inherit (lib.lists) map unique flatten;
  withDeps = p: [ p ] ++ p.rimeDependencies ++ p.propagatedBuildInputs;
in
unique (flatten (map withDeps rimePackages))
