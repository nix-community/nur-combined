{pkgs, ...}: 
let
  pkg = pkgs.callPackage ./package.nix {};
in
{
  home.packages = [
    pkg
  ];
}
