{ callPackage, ... }:
let
  flattenPkgs = callPackage ./flatten-pkgs.nix { };
  inherit (flattenPkgs) isDerivation isTargetPlatform;
in
rec {
  isBuildable = p: (isDerivation p) && !(p.meta.broken or false) && (isTargetPlatform p);

  isSourceFetchable = p: (isDerivation p) && (isTargetPlatform p);
}
