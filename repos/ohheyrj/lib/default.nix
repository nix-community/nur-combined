{ pkgs }:

let
  generated = (import ../_sources/generated.nix) {
    inherit (pkgs) fetchgit fetchurl fetchFromGitHub dockerTools;
  };
in
with pkgs.lib; {
  # Custom callPackage that injects generated sources
  callPackage = pkgName: pkgPath: 
    pkgs.callPackage pkgPath { generated = generated.${pkgName}; };
}
