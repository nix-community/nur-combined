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
  inherit (pkgs.lib)
    all
    filterAttrs
    isList
    pipe
    ;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isBuildable =
    _n: p:
    let
      licenseFromMeta = p.meta.license or [ ];
      licenseList = if isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
    in
    !(p.meta.broken or false) && all (license: license.free or true) licenseList;
  isCacheable = _n: p: !(p.preferLocalBuild or false);

  nurAttrs = import ./default.nix { inherit pkgs; };
  flattenPkgs = import lib/flatten.nix { inherit pkgs; };

  nurPkgs = pipe nurAttrs [
    (filterAttrs (n: _v: !isReserved n))
    flattenPkgs
  ];
in
rec {
  buildPkgs = filterAttrs isBuildable nurPkgs;
  cachePkgs = filterAttrs isCacheable buildPkgs;
}
