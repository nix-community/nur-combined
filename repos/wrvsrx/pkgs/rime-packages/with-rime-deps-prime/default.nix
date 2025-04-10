{ lib, buildEnv }:

rimePackages:

let
  inherit (lib.lists) map unique flatten;
  withDeps = p: [ p ] ++ p.propagatedBuildInputs;
  step = ps: unique (flatten (map withDeps ps));
  closure = lib.fix (f: ps: if ps == step ps then ps else f (step ps)) rimePackages;
in
buildEnv {
  name = "combined-rime-data";
  paths = closure;
  pathsToLink = [ "/share/rime-data" ];
  passthru.rimePackages = closure;
}
