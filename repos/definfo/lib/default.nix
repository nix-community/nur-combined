{ pkgs }:

let
  source = (import ../_sources/generated.nix) {
    inherit (pkgs)
      fetchgit
      fetchurl
      fetchFromGitHub
      dockerTools
      ;
  }; # nvfetcher
in
with pkgs.lib;
{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  callPackage =
    pkgName: (callPackageWith (pkgs // { source = source.${pkgName}; })) ../pkgs/${pkgName};
}
