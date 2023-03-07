{ self, futils, nixpkgs, ... }:
system:
let
  inherit (futils.lib) filterPackages flattenTree;
  pkgs = nixpkgs.legacyPackages.${system};
  packages = import "${self}/pkgs" { inherit pkgs; };
  flattenedPackages = flattenTree packages;
  finalPackages = filterPackages system flattenedPackages;
in
finalPackages
