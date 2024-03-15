{
  lib,
  system,
  callPackage,
  ...
}:
let
  flattenPkgs = callPackage ./flatten-pkgs.nix { };
  inherit (flattenPkgs) isDerivation isTargetPlatform;
in
rec {
  isBuildable =
    p:
    (isDerivation p)
    && !(p.meta.broken or false)
    && !(p.preferLocalBuild or false)
    && (isTargetPlatform p);
}
