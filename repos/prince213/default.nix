{
  pkgs ? import <nixpkgs> { },
}:
let
  overlay =
    final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ./pkgs;
    };

  pkgs' = pkgs.extend overlay;
in
{
  modules.default = ./modules/nixos;
  overlays.default = overlay;
}
// overlay pkgs' pkgs'
