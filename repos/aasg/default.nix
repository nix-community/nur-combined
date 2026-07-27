{ pkgs ? import <nixpkgs> { } }:

with import ./lib/extension.nix { inherit (pkgs) lib; };
let
  overlayToPackageSet = overlays: manifest:
    pipe overlays [
      pkgs.appendOverlays
      (copyAttrsByPath manifest)
      recurseIntoAttrsRecursive
      (mapAttrsRecursiveCond
        (set: set.recurseForDerivations or false)
        (path: drv:
          if drv ? meta.hydraPlatforms && drv.meta.hydraPlatforms == platforms.none
          then warn "aasg-nixexprs.${concatStringsSep "." path} is no longer supported; please switch to use the version in Nixpkgs" drv
          else drv))
    ];
  self = {
    lib = import ./lib { inherit (pkgs) lib; };
    modules = import ./modules;
    overlays = {
      pkgs = import ./pkgs/overlay.nix;
      patches = import ./patches/overlay.nix;
    };
    packageSets = {
      pkgs = overlayToPackageSet [ self.overlays.pkgs ] (import ./pkgs/manifest.nix);
      patches = overlayToPackageSet [ self.overlays.pkgs self.overlays.patches ] (import ./patches/manifest.nix);
    };
  };
in
foldl' recursiveUpdate self [
  self.packageSets.pkgs
  self.packageSets.patches
]
