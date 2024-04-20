{ lib }:

rimePackages:

let
  inherit (lib.lists) map unique flatten;
  withDeps = p: [ p ] ++ p.rimeDependencies ++ p.propagatedBuildInputs;
  step = ps: unique (flatten (map withDeps ps));
in
lib.fix (f: ps: if ps == step ps then ps else f (step ps)) rimePackages
