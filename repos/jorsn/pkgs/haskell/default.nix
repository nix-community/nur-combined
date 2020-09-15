{ lib, haskell }:

haskell // {
  packageOverrides = self: super:
    haskell.packageOverrides self super
    // lib.mapAttrs (n: p: super.callPackage p {}) {
      bibi = ./bibi.nix;
    };
}
