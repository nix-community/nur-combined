# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{
  pkgs ? import <nixpkgs> { },
}:

with builtins;
with pkgs.lib;
let
  nurAttrs = import ../default.nix { inherit pkgs; };
  nurPkgs =
    with nurAttrs.lib;
    flattenPkgs (
      listToAttrs (
        map (n: nameValuePair n nurAttrs.${n}) (filter (n: !isReserved n) (attrNames nurAttrs))
      )
    );
in
with nurAttrs.lib;
rec {
  buildPkgs = filter (p: isBuildable p && forSystem pkgs.stdenv.system p) nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
