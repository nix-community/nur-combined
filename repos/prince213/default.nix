{
  pkgs ? import <nixpkgs> { },
}:
let
  overlay =
    _: super:
    super.lib.packagesFromDirectoryRecursive {
      inherit (super) callPackage;
      directory = ./pkgs;
    };

  pkgs' = pkgs.extend overlay;
in
{
  modules.default = ./modules/nixos;
  overlays.default = overlay;
}
// overlay pkgs' pkgs'
