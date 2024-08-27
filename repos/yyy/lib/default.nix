{ pkgs }:

let
  generated = (import ../_sources/generated.nix) { inherit (pkgs) fetchgit fetchurl fetchFromGitHub dockerTools; }; # nvfetcher
in
with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  callPackage = pkgName: (callPackageWith (pkgs // { generated = generated.${pkgName}; })) ../pkgs/${pkgName};
}
