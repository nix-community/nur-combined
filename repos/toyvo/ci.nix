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

let

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs = nurAttrs.lib.flattenPkgs (
    builtins.listToAttrs (
      builtins.map (n: pkgs.lib.nameValuePair n nurAttrs.${n}) (
        builtins.filter (n: !nurAttrs.lib.isReserved n) (builtins.attrNames nurAttrs)
      )
    )
  );

in
rec {
  buildPkgs = builtins.filter nurAttrs.lib.isBuildable nurPkgs;
  cachePkgs = builtins.filter nurAttrs.lib.isCacheable buildPkgs;

  buildOutputs = builtins.concatMap nurAttrs.lib.outputsOf buildPkgs;
  cacheOutputs = builtins.concatMap nurAttrs.lib.outputsOf cachePkgs;
}
